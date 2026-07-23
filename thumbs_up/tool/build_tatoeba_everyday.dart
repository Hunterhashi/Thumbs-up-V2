/// Offline pipeline: download Tatoeba Everyday phrase pools (EN + DE),
/// filter them, and write JSON assets under `assets/phrases/`.
///
/// Run from the Flutter project root:
///   dart run tool/build_tatoeba_everyday.dart
///
/// Requires network access and `bunzip2` on PATH (macOS/Linux).
///
/// English uses the CC0 export. German CC0 is too small (~50 sentences), so
/// DE falls back to the full per-language export (CC BY 2.0 FR) — recorded in
/// `assets/phrases/manifest.json` and the in-app Credits line.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _engCc0Url =
    'https://downloads.tatoeba.org/exports/per_language/eng/eng_sentences_CC0.tsv.bz2';
const _deuCc0Url =
    'https://downloads.tatoeba.org/exports/per_language/deu/deu_sentences_CC0.tsv.bz2';
const _deuFullUrl =
    'https://downloads.tatoeba.org/exports/per_language/deu/deu_sentences.tsv.bz2';

const _cap = 800;
const _minLen = 15;
const _maxLen = 60;
const _deCc0MinViable = 200;

/// Letters (incl. Latin accents), spaces, common quotes, limited punctuation.
final _allowed = RegExp(r'''^[\p{L}\p{M} .,''""„“”?!;:\-…]+$''', unicode: true);
final _hasDigit = RegExp(r'\d');

Future<void> main() async {
  final root = _projectRoot();
  final cacheDir = Directory('${root.path}/tool/.tatoeba_cache');
  final outDir = Directory('${root.path}/assets/phrases');
  await cacheDir.create(recursive: true);
  await outDir.create(recursive: true);

  final engPath = await _downloadAndDecompress(
    cacheDir,
    'eng_sentences_CC0.tsv.bz2',
    _engCc0Url,
  );
  final eng = _filterSentences(await File(engPath).readAsLines());
  final engPicked = _shuffleTake(eng, _cap);

  // Prefer DE CC0; fall back to full DE export when the CC0 pool is too small.
  final deuCc0Path = await _downloadAndDecompress(
    cacheDir,
    'deu_sentences_CC0.tsv.bz2',
    _deuCc0Url,
  );
  var deu = _filterSentences(await File(deuCc0Path).readAsLines());
  var deuLicense = 'CC0 1.0';
  var deuSourceUrl = _deuCc0Url;

  if (deu.length < _deCc0MinViable) {
    stdout.writeln(
      'DE CC0 filtered pool is ${deu.length} (< $_deCc0MinViable); '
      'falling back to full DE export (CC BY 2.0 FR).',
    );
    final deuFullPath = await _downloadAndDecompress(
      cacheDir,
      'deu_sentences.tsv.bz2',
      _deuFullUrl,
    );
    deu = _filterSentences(await File(deuFullPath).readAsLines());
    deuLicense = 'CC BY 2.0 FR';
    deuSourceUrl = _deuFullUrl;
  }

  final deuPicked = _shuffleTake(deu, _cap);

  await File(
    '${outDir.path}/everyday_en.json',
  ).writeAsString('${const JsonEncoder.withIndent('  ').convert(engPicked)}\n');
  await File(
    '${outDir.path}/everyday_de.json',
  ).writeAsString('${const JsonEncoder.withIndent('  ').convert(deuPicked)}\n');

  final manifest = <String, Object>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'sourceIndex': 'https://downloads.tatoeba.org/exports/per_language/',
    'languages': {
      'en': {
        'license': 'CC0 1.0',
        'url': _engCc0Url,
        'filtered': eng.length,
        'shipped': engPicked.length,
      },
      'de': {
        'license': deuLicense,
        'url': deuSourceUrl,
        'filtered': deu.length,
        'shipped': deuPicked.length,
      },
    },
    'filter': {
      'minLength': _minLen,
      'maxLength': _maxLen,
      'noDigits': true,
      'lowercase': true,
      'cap': _cap,
    },
  };
  await File(
    '${outDir.path}/manifest.json',
  ).writeAsString('${const JsonEncoder.withIndent('  ').convert(manifest)}\n');

  stdout.writeln(
    'Wrote ${engPicked.length} EN (CC0) + ${deuPicked.length} DE ($deuLicense) '
    'phrases (filtered from ${eng.length} / ${deu.length}).',
  );
}

Directory _projectRoot() {
  final script = File.fromUri(Platform.script);
  return script.parent.parent;
}

Future<String> _downloadAndDecompress(
  Directory cacheDir,
  String bz2Name,
  String url,
) async {
  final bz2Path = '${cacheDir.path}/$bz2Name';
  final tsvPath = bz2Path.replaceAll('.bz2', '');
  final tsvFile = File(tsvPath);

  if (!tsvFile.existsSync()) {
    stdout.writeln('Downloading $url …');
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw StateError('Download failed (${response.statusCode}): $url');
      }
      final sink = File(bz2Path).openWrite();
      await response.pipe(sink);
    } finally {
      client.close(force: true);
    }

    stdout.writeln('Decompressing $bz2Name …');
    final result = await Process.run('bunzip2', ['-kf', bz2Path]);
    if (result.exitCode != 0) {
      throw StateError('bunzip2 failed: ${result.stderr}');
    }
  } else {
    stdout.writeln('Using cached $tsvPath');
  }

  return tsvPath;
}

List<String> _filterSentences(List<String> lines) {
  final seen = <String>{};
  final out = <String>[];

  for (final line in lines) {
    if (line.isEmpty) continue;
    final parts = line.split('\t');
    if (parts.length < 3) continue;
    var text = parts[2].trim();
    if (text.isEmpty) continue;
    if (_hasDigit.hasMatch(text)) continue;

    // Normalize fancy quotes before the allow-list check / lowercase.
    text = text
        .replaceAll('„', '"')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‚', "'")
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('…', '...')
        .toLowerCase();

    if (text.length < _minLen || text.length > _maxLen) continue;
    if (!_allowed.hasMatch(text)) continue;
    if (!text.contains(' ')) continue;
    if (!seen.add(text)) continue;
    out.add(text);
  }
  return out;
}

List<String> _shuffleTake(List<String> source, int cap) {
  final copy = List<String>.from(source);
  copy.shuffle(Random(42));
  if (copy.length <= cap) return copy;
  return copy.sublist(0, cap);
}
