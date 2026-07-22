import 'package:flutter/material.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/phrase_category.dart';
import 'package:thumbs_up/models/session_result.dart';
import 'package:thumbs_up/screens/home_screen.dart';
import 'package:thumbs_up/screens/practice_screen.dart';
import 'package:thumbs_up/screens/result_screen.dart';
import 'package:thumbs_up/screens/settings_screen.dart';

/// Centralizes navigation for Launch → Home → Practice → Results so
/// individual screens don't need to know route/transition details.
class AppRouter {
  const AppRouter._();

  static const Duration _transitionDuration = Duration(milliseconds: 400);

  /// Cross-fade route, used for the Launch → Home handoff.
  static PageRoute<void> fadeThrough(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: _transitionDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Replaces the whole stack with [HomeScreen] (used after Launch, and
  /// whenever the user taps "Home" to fully exit a run).
  static void toHome(BuildContext context) {
    Navigator.of(
      context,
    ).pushAndRemoveUntil(fadeThrough(const HomeScreen()), (route) => false);
  }

  /// Pushes the Settings screen (haptics/HUD/theme toggles).
  static void toSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  /// Pushes a new Practice run for [difficulty] using [category]'s phrase
  /// pack.
  static void toPractice(
    BuildContext context,
    Difficulty difficulty,
    PhraseCategory category,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PracticeScreen(difficulty: difficulty, category: category),
      ),
    );
  }

  /// Starts a fresh Practice run with a new phrase from [category]'s pack,
  /// in place of the current one (used by Results' "Next phrase" action so
  /// the stack doesn't keep growing).
  static void nextPhrase(
    BuildContext context,
    Difficulty difficulty,
    PhraseCategory category,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            PracticeScreen(difficulty: difficulty, category: category),
      ),
    );
  }

  /// Starts a fresh Practice run with the same [phrase] just completed
  /// (used by Results' "Repeat" action).
  static void repeatPhrase(
    BuildContext context,
    Difficulty difficulty,
    PhraseCategory category,
    String phrase,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PracticeScreen(
          difficulty: difficulty,
          category: category,
          initialPhrase: phrase,
        ),
      ),
    );
  }

  /// Replaces the current Practice screen with the Results screen so the
  /// back button from Results returns to Home, not to a finished run.
  static void toResult(
    BuildContext context,
    SessionResult result, {
    bool isNewBest = false,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(result: result, isNewBest: isNewBest),
      ),
    );
  }
}
