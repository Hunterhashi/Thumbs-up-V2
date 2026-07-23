import 'dart:math';

/// Flattens phrase lists into individual words and hands them out in a
/// shuffle-once cycle that refills when exhausted — enough for an endless
/// 30s Speed Stream run without obvious short-term repeats.
class WordDeck {
  WordDeck(List<String> phrases, {Random? random})
    : _random = random ?? Random(),
      _words = _flatten(phrases) {
    _reshuffle();
  }

  final Random _random;
  final List<String> _words;
  List<String> _order = [];
  int _cursor = 0;

  static List<String> _flatten(List<String> phrases) {
    final words = <String>[];
    for (final phrase in phrases) {
      for (final part in phrase.split(RegExp(r'\s+'))) {
        final trimmed = part.trim();
        if (trimmed.isNotEmpty) words.add(trimmed);
      }
    }
    return words;
  }

  void _reshuffle() {
    if (_words.isEmpty) {
      _order = const ['go'];
      return;
    }
    _order = List<String>.from(_words)..shuffle(_random);
    _cursor = 0;
  }

  String next() {
    if (_cursor >= _order.length) {
      _reshuffle();
    }
    final word = _order[_cursor];
    _cursor++;
    return word;
  }
}
