import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the one-time onboarding tips (shown on the first Home
/// screen visit) have already been dismissed, backed by
/// `shared_preferences`.
class OnboardingStore {
  OnboardingStore._();

  static const String _hasSeenTipsKey = 'has_seen_onboarding_tips';

  static Future<bool> hasSeenTips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenTipsKey) ?? false;
  }

  static Future<void> markTipsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenTipsKey, true);
  }
}
