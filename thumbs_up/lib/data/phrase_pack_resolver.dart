import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:thumbs_up/data/easy_phrases_en.dart';
import 'package:thumbs_up/data/easy_phrases_punctuation_numbers_en.dart';
import 'package:thumbs_up/models/phrase_category.dart';
import 'package:thumbs_up/progress/settings_store.dart';

/// Resolves the phrase list for a [PhraseCategory] + UI [Locale].
///
/// Everyday packs are Tatoeba-derived JSON assets (EN CC0 / DE CC BY when
/// CC0 was too small). Punctuation & Numbers stays the hand-written English
/// list regardless of locale.
class PhrasePackResolver {
  PhrasePackResolver._();

  static const String _everydayEnAsset = 'assets/phrases/everyday_en.json';
  static const String _everydayDeAsset = 'assets/phrases/everyday_de.json';

  static List<String>? _everydayEn;
  static List<String>? _everydayDe;
  static bool _prefetchStarted = false;

  /// Prefetch Everyday JSON packs so Practice does not hitch on first open.
  static Future<void> prefetch() async {
    if (_prefetchStarted) return;
    _prefetchStarted = true;
    await Future.wait([
      _loadEveryday(const Locale('en')),
      _loadEveryday(const Locale('de')),
    ]);
  }

  /// Phrase language: German only when the active UI locale is `de`;
  /// everything else falls back to English.
  static Locale phraseLocale([Locale? uiLocale]) {
    final locale =
        uiLocale ??
        SettingsStore.current.locale ??
        WidgetsBinding.instance.platformDispatcher.locale;
    return locale.languageCode == 'de'
        ? const Locale('de')
        : const Locale('en');
  }

  /// Synchronous lookup after [prefetch] (or after a prior await of
  /// [phrasesFor]). Safe to call from Practice init once packs are warm.
  static List<String> phrases(PhraseCategory category, {Locale? uiLocale}) {
    if (category == PhraseCategory.punctuationNumbers) {
      return easyPhrasesPunctuationNumbersEn;
    }
    final lang = phraseLocale(uiLocale);
    if (lang.languageCode == 'de') {
      return _everydayDe ?? easyPhrasesEn;
    }
    return _everydayEn ?? easyPhrasesEn;
  }

  /// Ensures Everyday packs for [uiLocale] are loaded, then returns
  /// [phrases]. Prefer [prefetch] at app start; use this when unsure.
  static Future<List<String>> phrasesFor(
    PhraseCategory category, {
    Locale? uiLocale,
  }) async {
    if (category == PhraseCategory.everyday) {
      await _loadEveryday(phraseLocale(uiLocale));
    }
    return phrases(category, uiLocale: uiLocale);
  }

  static Future<void> _loadEveryday(Locale locale) async {
    if (locale.languageCode == 'de') {
      _everydayDe ??= await _loadJsonList(_everydayDeAsset);
    } else {
      _everydayEn ??= await _loadJsonList(_everydayEnAsset);
    }
  }

  static Future<List<String>> _loadJsonList(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! List) return easyPhrasesEn;
      return decoded.map((e) => e.toString()).toList(growable: false);
    } catch (_) {
      return easyPhrasesEn;
    }
  }
}
