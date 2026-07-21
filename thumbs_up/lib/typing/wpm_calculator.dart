/// Pure scoring math shared by the live HUD and the Results screen.
///
/// Kept dependency-free and stateless so it is trivial to unit test.
class WpmCalculator {
  const WpmCalculator._();

  /// Words per minute using the standard "5 characters = 1 word" measure.
  static double wpm({required int correctChars, required Duration elapsed}) {
    final minutes = elapsed.inMilliseconds / 60000.0;
    if (minutes <= 0) return 0;
    return (correctChars / 5) / minutes;
  }

  /// Keystroke-based accuracy as a percentage (0-100).
  static double accuracyPercent({
    required int correctChars,
    required int mistakes,
  }) {
    final total = correctChars + mistakes;
    if (total <= 0) return 100;
    return (correctChars / total) * 100;
  }
}
