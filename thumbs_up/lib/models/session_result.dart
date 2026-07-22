import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/phrase_category.dart';

/// Final stats produced by a Practice run, shown on the Results screen.
class SessionResult {
  const SessionResult({
    required this.difficulty,
    required this.category,
    required this.phrase,
    required this.elapsed,
    required this.correctChars,
    required this.mistakes,
    required this.backspaces,
  });

  final Difficulty difficulty;
  final PhraseCategory category;
  final String phrase;
  final Duration elapsed;

  /// Number of characters typed correctly (final, matched text length).
  final int correctChars;

  /// Number of wrong keystrokes made while typing (even if later corrected).
  final int mistakes;

  /// Number of backspace presses (tracked separately, does not affect
  /// [mistakes]).
  final int backspaces;

  /// Total keystrokes considered for accuracy: correct chars + mistakes.
  int get totalKeystrokes => correctChars + mistakes;

  double get minutes => elapsed.inMilliseconds / 60000.0;

  /// Words per minute, using the standard "5 characters = 1 word" measure.
  double get wpm {
    if (minutes <= 0) return 0;
    return (correctChars / 5) / minutes;
  }

  /// Accuracy as a percentage (0-100), keystroke-based.
  double get accuracyPercent {
    if (totalKeystrokes <= 0) return 100;
    return (correctChars / totalKeystrokes) * 100;
  }
}
