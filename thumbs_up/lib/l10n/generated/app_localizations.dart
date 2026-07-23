import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// The app's display name (window/task-switcher title).
  ///
  /// In en, this message translates to:
  /// **'Thumbs Up'**
  String get appTitle;

  /// Home screen headline.
  ///
  /// In en, this message translates to:
  /// **'Choose Your\nChallenge'**
  String get homeHeadline;

  /// Home screen subtitle under the headline.
  ///
  /// In en, this message translates to:
  /// **'Pick a difficulty and start typing'**
  String get homeSubtitle;

  /// Tooltip for the Home screen's settings icon button.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// Snackbar shown when tapping an unavailable difficulty (Medium/Pro).
  ///
  /// In en, this message translates to:
  /// **'{difficulty} (Speed Stream) is coming soon.'**
  String comingSoonSnackbar(String difficulty);

  /// No description provided for @difficultyEasyLabel.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasyLabel;

  /// No description provided for @difficultyMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMediumLabel;

  /// No description provided for @difficultyProLabel.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get difficultyProLabel;

  /// No description provided for @difficultyEasySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn accuracy'**
  String get difficultyEasySubtitle;

  /// No description provided for @difficultyMediumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speed Stream'**
  String get difficultyMediumSubtitle;

  /// No description provided for @difficultyProSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speed Stream+'**
  String get difficultyProSubtitle;

  /// No description provided for @difficultyEasyDescription.
  ///
  /// In en, this message translates to:
  /// **'Short phrases · 30s loop'**
  String get difficultyEasyDescription;

  /// No description provided for @difficultyMediumDescription.
  ///
  /// In en, this message translates to:
  /// **'Comfortable scrolling pace · build rhythm'**
  String get difficultyMediumDescription;

  /// No description provided for @difficultyProDescription.
  ///
  /// In en, this message translates to:
  /// **'Fast scrolling pace · master speed'**
  String get difficultyProDescription;

  /// Small badge on an unavailable (Medium/Pro) difficulty card.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get difficultySoonBadge;

  /// Personal-best pill on a difficulty card.
  ///
  /// In en, this message translates to:
  /// **'Best: {wpm} WPM'**
  String difficultyBestWpm(int wpm);

  /// No description provided for @categoryEverydayLabel.
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get categoryEverydayLabel;

  /// No description provided for @categoryPunctuationNumbersLabel.
  ///
  /// In en, this message translates to:
  /// **'Punctuation & Numbers'**
  String get categoryPunctuationNumbersLabel;

  /// No description provided for @categoryEverydayDescription.
  ///
  /// In en, this message translates to:
  /// **'Casual, lowercase sentences'**
  String get categoryEverydayDescription;

  /// No description provided for @categoryPunctuationNumbersDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice numbers, symbols and punctuation'**
  String get categoryPunctuationNumbersDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get settingsSectionPractice;

  /// No description provided for @settingsHapticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get settingsHapticsTitle;

  /// No description provided for @settingsHapticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on correct and incorrect keys'**
  String get settingsHapticsSubtitle;

  /// No description provided for @settingsHudTitle.
  ///
  /// In en, this message translates to:
  /// **'Live stats HUD'**
  String get settingsHudTitle;

  /// No description provided for @settingsHudSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show time, WPM and accuracy while typing'**
  String get settingsHudSubtitle;

  /// No description provided for @settingsSectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsSectionAppearance;

  /// No description provided for @themeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// No description provided for @settingsSectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsSectionLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Everyday phrases from Tatoeba (EN: CC0, DE: CC BY 2.0 FR).'**
  String get settingsCredits;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Thumbs Up'**
  String get onboardingTitle;

  /// No description provided for @onboardingTip1.
  ///
  /// In en, this message translates to:
  /// **'Pick a difficulty, then type the highlighted phrase as fast and accurately as you can.'**
  String get onboardingTip1;

  /// No description provided for @onboardingTip2.
  ///
  /// In en, this message translates to:
  /// **'Correct keys turn green, mistakes turn red — backspace doesn\'t erase the mistake count.'**
  String get onboardingTip2;

  /// No description provided for @onboardingTip3.
  ///
  /// In en, this message translates to:
  /// **'Tap the pause button anytime; your personal best is saved automatically.'**
  String get onboardingTip3;

  /// No description provided for @onboardingGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get onboardingGotIt;

  /// No description provided for @statsTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get statsTime;

  /// No description provided for @statsTimeLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get statsTimeLeft;

  /// No description provided for @statsWpm.
  ///
  /// In en, this message translates to:
  /// **'WPM'**
  String get statsWpm;

  /// No description provided for @statsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get statsAccuracy;

  /// No description provided for @resultHeadline.
  ///
  /// In en, this message translates to:
  /// **'Nice work!'**
  String get resultHeadline;

  /// Results screen subheading: difficulty, category and elapsed time.
  ///
  /// In en, this message translates to:
  /// **'{difficulty} · {category} · {elapsed}'**
  String resultSummaryLine(String difficulty, String category, String elapsed);

  /// No description provided for @resultNewBestBadge.
  ///
  /// In en, this message translates to:
  /// **'New personal best'**
  String get resultNewBestBadge;

  /// No description provided for @resultStatMistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get resultStatMistakes;

  /// No description provided for @resultStatBackspaces.
  ///
  /// In en, this message translates to:
  /// **'Backspaces'**
  String get resultStatBackspaces;

  /// No description provided for @resultStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get resultStatCompleted;

  /// No description provided for @resultStatMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get resultStatMissed;

  /// No description provided for @resultNextPhrase.
  ///
  /// In en, this message translates to:
  /// **'Next phrase'**
  String get resultNextPhrase;

  /// No description provided for @resultPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get resultPlayAgain;

  /// No description provided for @resultRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get resultRepeat;

  /// No description provided for @resultChangeDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Change difficulty'**
  String get resultChangeDifficulty;

  /// No description provided for @exitDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave practice?'**
  String get exitDialogTitle;

  /// No description provided for @exitDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Your progress on this run will be lost.'**
  String get exitDialogContent;

  /// No description provided for @exitDialogKeepTyping.
  ///
  /// In en, this message translates to:
  /// **'Keep typing'**
  String get exitDialogKeepTyping;

  /// No description provided for @exitDialogLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get exitDialogLeave;

  /// No description provided for @pausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedTitle;

  /// No description provided for @pausedResumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get pausedResumeButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
