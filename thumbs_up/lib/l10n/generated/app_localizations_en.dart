// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Thumbs Up';

  @override
  String get homeHeadline => 'Choose Your\nChallenge';

  @override
  String get homeSubtitle => 'Pick a difficulty and start typing';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String comingSoonSnackbar(String difficulty) {
    return '$difficulty (Speed Stream) is coming soon.';
  }

  @override
  String get difficultyEasyLabel => 'Easy';

  @override
  String get difficultyMediumLabel => 'Medium';

  @override
  String get difficultyProLabel => 'Pro';

  @override
  String get difficultyEasySubtitle => 'Learn accuracy';

  @override
  String get difficultyMediumSubtitle => 'Speed Stream';

  @override
  String get difficultyProSubtitle => 'Speed Stream+';

  @override
  String get difficultyEasyDescription =>
      'Short, static phrases · no time pressure';

  @override
  String get difficultyMediumDescription =>
      'Comfortable scrolling pace · build rhythm';

  @override
  String get difficultyProDescription => 'Fast scrolling pace · master speed';

  @override
  String get difficultySoonBadge => 'Soon';

  @override
  String difficultyBestWpm(int wpm) {
    return 'Best: $wpm WPM';
  }

  @override
  String get categoryEverydayLabel => 'Everyday';

  @override
  String get categoryPunctuationNumbersLabel => 'Punctuation & Numbers';

  @override
  String get categoryEverydayDescription => 'Casual, lowercase sentences';

  @override
  String get categoryPunctuationNumbersDescription =>
      'Practice numbers, symbols and punctuation';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionPractice => 'Practice';

  @override
  String get settingsHapticsTitle => 'Haptic feedback';

  @override
  String get settingsHapticsSubtitle => 'Vibrate on correct and incorrect keys';

  @override
  String get settingsHudTitle => 'Live stats HUD';

  @override
  String get settingsHudSubtitle => 'Show time, WPM and accuracy while typing';

  @override
  String get settingsSectionAppearance => 'Appearance';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get settingsSectionLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get settingsCredits =>
      'Everyday phrases from Tatoeba (EN: CC0, DE: CC BY 2.0 FR).';

  @override
  String get onboardingTitle => 'Welcome to Thumbs Up';

  @override
  String get onboardingTip1 =>
      'Pick a difficulty, then type the highlighted phrase as fast and accurately as you can.';

  @override
  String get onboardingTip2 =>
      'Correct keys turn green, mistakes turn red — backspace doesn\'t erase the mistake count.';

  @override
  String get onboardingTip3 =>
      'Tap the pause button anytime; your personal best is saved automatically.';

  @override
  String get onboardingGotIt => 'Got it';

  @override
  String get statsTime => 'Time';

  @override
  String get statsTimeLeft => 'Left';

  @override
  String get statsWpm => 'WPM';

  @override
  String get statsAccuracy => 'Accuracy';

  @override
  String get resultHeadline => 'Nice work!';

  @override
  String resultSummaryLine(String difficulty, String category, String elapsed) {
    return '$difficulty · $category · $elapsed';
  }

  @override
  String get resultNewBestBadge => 'New personal best';

  @override
  String get resultStatMistakes => 'Mistakes';

  @override
  String get resultStatBackspaces => 'Backspaces';

  @override
  String get resultStatCompleted => 'Completed';

  @override
  String get resultStatMissed => 'Missed';

  @override
  String get resultNextPhrase => 'Next phrase';

  @override
  String get resultPlayAgain => 'Play again';

  @override
  String get resultRepeat => 'Repeat';

  @override
  String get resultChangeDifficulty => 'Change difficulty';

  @override
  String get exitDialogTitle => 'Leave practice?';

  @override
  String get exitDialogContent => 'Your progress on this run will be lost.';

  @override
  String get exitDialogKeepTyping => 'Keep typing';

  @override
  String get exitDialogLeave => 'Leave';

  @override
  String get pausedTitle => 'Paused';

  @override
  String get pausedResumeButton => 'Resume';
}
