import 'package:shared_preferences/shared_preferences.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/session_result.dart';

/// A saved personal best for a single [Difficulty].
class PersonalBest {
  const PersonalBest({required this.wpm, required this.accuracyPercent});

  final double wpm;
  final double accuracyPercent;
}

/// Persists the best [SessionResult] (by WPM) reached per [Difficulty],
/// backed by `shared_preferences`.
class PersonalBestStore {
  PersonalBestStore._();

  static String _wpmKey(Difficulty difficulty) =>
      'personal_best_wpm_${difficulty.name}';

  static String _accuracyKey(Difficulty difficulty) =>
      'personal_best_accuracy_${difficulty.name}';

  /// The saved best for [difficulty], or null if none has been set yet.
  static Future<PersonalBest?> load(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final wpm = prefs.getDouble(_wpmKey(difficulty));
    if (wpm == null) return null;
    return PersonalBest(
      wpm: wpm,
      accuracyPercent: prefs.getDouble(_accuracyKey(difficulty)) ?? 0,
    );
  }

  /// Saves [result] as the new best for its difficulty when it beats (or no
  /// best exists yet for) the currently stored one. Returns whether it
  /// became the new best.
  static Future<bool> saveIfBest(SessionResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _wpmKey(result.difficulty);
    final currentBestWpm = prefs.getDouble(key);
    if (currentBestWpm != null && result.wpm <= currentBestWpm) {
      return false;
    }
    await prefs.setDouble(key, result.wpm);
    await prefs.setDouble(
      _accuracyKey(result.difficulty),
      result.accuracyPercent,
    );
    return true;
  }
}
