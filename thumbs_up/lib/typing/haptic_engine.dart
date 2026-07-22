import 'package:flutter/services.dart';
import 'package:thumbs_up/progress/settings_store.dart';

/// Thin wrapper around [HapticFeedback] for typing feedback.
///
/// Kept as a single entry point so the Settings "Haptic feedback" toggle
/// only needs to change this class.
class HapticEngine {
  const HapticEngine();

  /// Subtle tap for a correctly typed character.
  void correctKey() {
    if (!SettingsStore.current.hapticsEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Heavier buzz for a mistyped character.
  void wrongKey() {
    if (!SettingsStore.current.hapticsEnabled) return;
    HapticFeedback.heavyImpact();
  }
}
