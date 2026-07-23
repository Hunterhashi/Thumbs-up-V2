// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Thumbs Up';

  @override
  String get homeHeadline => 'Wähle deine\nHerausforderung';

  @override
  String get homeSubtitle =>
      'Wähle einen Schwierigkeitsgrad und beginne zu tippen';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String comingSoonSnackbar(String difficulty) {
    return '$difficulty (Speed Stream) folgt in Kürze.';
  }

  @override
  String get difficultyEasyLabel => 'Leicht';

  @override
  String get difficultyMediumLabel => 'Mittel';

  @override
  String get difficultyProLabel => 'Profi';

  @override
  String get difficultyEasySubtitle => 'Genauigkeit lernen';

  @override
  String get difficultyMediumSubtitle => 'Speed Stream';

  @override
  String get difficultyProSubtitle => 'Speed Stream+';

  @override
  String get difficultyEasyDescription => 'Kurze, feste Sätze · kein Zeitdruck';

  @override
  String get difficultyMediumDescription =>
      'Angenehmes Scroll-Tempo · Rhythmus aufbauen';

  @override
  String get difficultyProDescription =>
      'Schnelles Scroll-Tempo · Geschwindigkeit meistern';

  @override
  String get difficultySoonBadge => 'Bald';

  @override
  String difficultyBestWpm(int wpm) {
    return 'Bestwert: $wpm WPM';
  }

  @override
  String get categoryEverydayLabel => 'Alltag';

  @override
  String get categoryPunctuationNumbersLabel => 'Satzzeichen & Zahlen';

  @override
  String get categoryEverydayDescription => 'Lockere Sätze in Kleinschreibung';

  @override
  String get categoryPunctuationNumbersDescription =>
      'Übe Zahlen, Symbole und Satzzeichen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSectionPractice => 'Training';

  @override
  String get settingsHapticsTitle => 'Haptisches Feedback';

  @override
  String get settingsHapticsSubtitle =>
      'Vibration bei richtigen und falschen Tasten';

  @override
  String get settingsHudTitle => 'Live-Statistik-Anzeige';

  @override
  String get settingsHudSubtitle =>
      'Zeit, WPM und Genauigkeit während des Tippens anzeigen';

  @override
  String get settingsSectionAppearance => 'Erscheinungsbild';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Hell';

  @override
  String get themeModeDark => 'Dunkel';

  @override
  String get settingsSectionLanguage => 'Sprache';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get settingsCredits =>
      'Alltagssätze von Tatoeba (EN: CC0, DE: CC BY 2.0 FR).';

  @override
  String get onboardingTitle => 'Willkommen bei Thumbs Up';

  @override
  String get onboardingTip1 =>
      'Wähle einen Schwierigkeitsgrad und tippe den hervorgehobenen Satz so schnell und genau wie möglich.';

  @override
  String get onboardingTip2 =>
      'Richtige Tasten werden grün, Fehler rot — Rückschritt löscht die Fehlerzahl nicht.';

  @override
  String get onboardingTip3 =>
      'Tippe jederzeit auf Pause; dein persönlicher Bestwert wird automatisch gespeichert.';

  @override
  String get onboardingGotIt => 'Alles klar';

  @override
  String get statsTime => 'Zeit';

  @override
  String get statsTimeLeft => 'Rest';

  @override
  String get statsWpm => 'WPM';

  @override
  String get statsAccuracy => 'Genauigkeit';

  @override
  String get resultHeadline => 'Gut gemacht!';

  @override
  String resultSummaryLine(String difficulty, String category, String elapsed) {
    return '$difficulty · $category · $elapsed';
  }

  @override
  String get resultNewBestBadge => 'Neue persönliche Bestleistung';

  @override
  String get resultStatMistakes => 'Fehler';

  @override
  String get resultStatBackspaces => 'Rückschritte';

  @override
  String get resultStatCompleted => 'Geschafft';

  @override
  String get resultStatMissed => 'Verpasst';

  @override
  String get resultNextPhrase => 'Nächster Satz';

  @override
  String get resultPlayAgain => 'Nochmal spielen';

  @override
  String get resultRepeat => 'Wiederholen';

  @override
  String get resultChangeDifficulty => 'Schwierigkeit ändern';

  @override
  String get exitDialogTitle => 'Übung verlassen?';

  @override
  String get exitDialogContent =>
      'Dein Fortschritt in diesem Durchlauf geht verloren.';

  @override
  String get exitDialogKeepTyping => 'Weiter tippen';

  @override
  String get exitDialogLeave => 'Verlassen';

  @override
  String get pausedTitle => 'Pausiert';

  @override
  String get pausedResumeButton => 'Fortsetzen';
}
