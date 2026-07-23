import 'package:thumbs_up/l10n/generated/app_localizations.dart';

/// Practice difficulty levels available from the home screen.
///
/// `easy` uses a static Phrase Stream. `medium` and `pro` use the scrolling
/// "Speed Stream" treadmill (see `SpeedStreamEngine`).
///
/// Display strings take [AppLocalizations] rather than being plain getters,
/// since they need to reflect the user's chosen language.
enum Difficulty {
  easy,
  medium,
  pro;

  String label(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasyLabel,
    Difficulty.medium => l10n.difficultyMediumLabel,
    Difficulty.pro => l10n.difficultyProLabel,
  };

  String subtitle(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasySubtitle,
    Difficulty.medium => l10n.difficultyMediumSubtitle,
    Difficulty.pro => l10n.difficultyProSubtitle,
  };

  String description(AppLocalizations l10n) => switch (this) {
    Difficulty.easy => l10n.difficultyEasyDescription,
    Difficulty.medium => l10n.difficultyMediumDescription,
    Difficulty.pro => l10n.difficultyProDescription,
  };

  /// All difficulties are playable (Easy = static Phrase Stream; Medium/Pro
  /// = Speed Stream treadmill).
  bool get isAvailable => true;
}
