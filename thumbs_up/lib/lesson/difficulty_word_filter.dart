import 'package:thumbs_up/lesson/word_deck.dart';
import 'package:thumbs_up/models/difficulty.dart';

/// Picks Speed Stream words from a phrase pack with a difficulty-based
/// minimum length so Medium/Pro feel harder than a raw Everyday flatten.
///
/// Easy does not use this helper (it types full phrases via [PhraseDeck]).
class DifficultyWordFilter {
  DifficultyWordFilter._();

  static const int _minViableWords = 40;

  /// Medium: words of length ≥ 4. Pro: ≥ 6. Falls back to the unfiltered
  /// flatten when the filtered set would be too small to run a 30s stream.
  static List<String> wordsForDifficulty(
    List<String> phrases,
    Difficulty difficulty,
  ) {
    final all = WordDeck.flatten(phrases);
    final minLen = switch (difficulty) {
      Difficulty.medium => 4,
      Difficulty.pro => 6,
      Difficulty.easy => 0,
    };
    if (minLen <= 0) return all;

    final filtered = all.where((w) => w.length >= minLen).toList();
    if (filtered.length < _minViableWords) return all;
    return filtered;
  }
}
