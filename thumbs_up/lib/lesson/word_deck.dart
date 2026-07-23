import 'dart:math';

/// Flattens phrase lists into individual words and hands them out in a
/// shuffle-once cycle that refills when exhausted — enough for an endless
/// 30s Speed Stream run without obvious short-term repeats.
class WordDeck {
  /// Builds a deck by splitting [phrases] on whitespace.
  WordDeck(List<String> phrases, {Random? random})
    : this.fromWords(flatten(phrases), random: random);

  /// Builds a deck from an already-flattened word list (e.g. after
  /// [DifficultyWordFilter.wordsForDifficulty]).
  WordDeck.fromWords(List<String> words, {Random? random})
    : _random = random ?? Random(),
      _words = List<String>.from(words) {
    _reshuffle();
  }

  final Random _random;
  final List<String> _words;
  List<String> _order = [];
  int _cursor = 0;

  /// Splits each phrase on whitespace into non-empty word tokens.
  static List<String> flatten(List<String> phrases) {
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
