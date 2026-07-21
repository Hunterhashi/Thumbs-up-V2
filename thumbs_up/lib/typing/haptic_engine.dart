import 'package:flutter/services.dart';

/// Thin wrapper around [HapticFeedback] for typing feedback.
///
/// Kept as a single entry point so a future Settings toggle
/// (haptics on/off) only needs to change this class.
class HapticEngine {
  const HapticEngine();

  /// Subtle tap for a correctly typed character.
  void correctKey() {
    HapticFeedback.lightImpact();
  }

  /// Heavier buzz for a mistyped character.
  void wrongKey() {
    HapticFeedback.heavyImpact();
  }
}
