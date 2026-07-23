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
    this.completedWords = 0,
    this.missedWords = 0,
  });

  final Difficulty difficulty;
  final PhraseCategory category;

  /// Easy: the phrase just typed. Speed Stream: a short label (not replayed).
  final String phrase;
  final Duration elapsed;

  /// Number of characters typed correctly (matched against targets).
  final int correctChars;

  /// Number of wrong keystrokes made while typing (even if later corrected).
  final int mistakes;

  /// Number of backspace presses (tracked separately, does not affect
  /// [mistakes]).
  final int backspaces;

  /// Speed Stream only: words typed fully before they scrolled off.
  final int completedWords;

  /// Speed Stream only: words that exited the left edge unfinished.
  final int missedWords;

  /// Whether this result came from a Medium/Pro Speed Stream run.
  bool get isSpeedStream =>
      difficulty == Difficulty.medium || difficulty == Difficulty.pro;

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
