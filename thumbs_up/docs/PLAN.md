# Thumbs Up (mobile typing trainer) MVP plan

> This is the canonical, in-repo copy of the project plan. It's meant to be the
> first thing an agent (or you) reads when starting a new session on this app.
> Keep the **Status / todo checklist** and **Progress log** sections below
> up to date as work happens; the detailed spec sections further down are
> mostly stable reference material.

## Status / todo checklist
- [x] Create the Flutter project (`thumbs_up`) with app name "Thumbs Up"
- [x] Add workflow guardrails (`.cursor/rules/*.mdc`) to prevent half-code / PATH / stability issues
- [x] Pre-flight checklist run (PATH, `flutter doctor`, `flutter devices`)
- [x] Brand icon added as `assets/brand/icon.png`, theme based on it
- [x] `lib/` folder structure created (theme, navigation, screens, models, typing, lesson, data)
- [x] `AppTheme` (light + dark) with brand tokens
- [x] Navigation shell (`lib/navigation/app_router.dart`)
- [x] `LaunchScreen` + `HomeScreen` (difficulty selection)
- [x] `PracticeScreen` (static Phrase Stream, hidden input, live HUD)
- [x] `ResultScreen` (WPM/accuracy/mistakes/backspaces)
- [x] Practice controls: top bar Back/Restart, exit-confirm dialog, and Pause/Resume (with correct timer handling)
- [x] Results actions: Next phrase / Repeat / Change difficulty
- [x] Local persistence: personal best per difficulty + one-time onboarding tips
- [x] Settings (E): haptics on/off, live HUD on/off, theme mode (system/light/dark)
- [x] Phrase packs / categories (Easy: Everyday + Punctuation & Numbers, picked on Home)
- [x] Localization (English + German UI strings + language selector in Settings; phrase content still English-only)
- [x] Sentence library (Tatoeba Everyday EN/DE offline JSON; Punctuation pack remains hand-written EN)
- [x] Medium/Pro "Speed Stream" (treadmill) mode + scoring, speed tuned on-device
- [x] Phrase lists + scoring logic per difficulty (beyond the Easy starter list) — Medium ≥4 / Pro ≥6 word floors on Speed Stream; same scoring formulas
- [x] Verification: `flutter analyze` clean, widget test passes, app boots/runs

## Post-MVP UI polish / bugfixes
- [x] Schritt 1: Live-HUD gelbe Badges (Dark-Mode-Lesbarkeit für Zeit/WPM/Genauigkeit)
- [x] Schritt 2: Easy Fertigstellung → Results Navigation härten
- [x] Schritt 3: Easy 30s Phrase-Loop + Slide-Animation
- [ ] Schritt 4: Pro Timer An/Aus + Speed-Einstellung — **Later tweaks** (kein Code in dieser Welle)

## Assumptions (to keep it simple)
- We'll build with **Flutter** and target **iOS + Android**.
- **Easy**: one run = **30s phrase loop** (finish a line → next line animates in; Results when the timer ends).
- **Medium/Pro ("Speed Stream")**: one run = **time-based** (endless word flow during the timer).
- Scoring is based on **time + per-keystroke mistakes** (so accuracy isn't always 100% even if the user corrects errors).
- The visual design will be **based on the provided yellow "thumbs up" icon**.

## Missing "senior dev" decisions (locked early)
- **Final app naming**: **"Thumbs Up"** (matches the icon + wordmark).
- **Bundle/package id**: kept as Flutter defaults for MVP; set a final reverse-DNS id before store release.
- **Exact scoring rules**:
  - Mistakes are counted when a wrong character is typed, even if later corrected.
  - Backspace doesn't "erase" the mistake count.
  - Accuracy is **keystroke-based** (recommended for mobile), not final-text-based.
- **Start behavior**: timer starts on **first keystroke** (simple).
- **Accessibility**:
  - Don't rely on red/green only (add underline/background cues for errors).
  - Support larger text sizes (Dynamic Type) and clear focus states.
- **Native polish (later)**:
  - Generate launcher icons from the PNG.
  - Add a native splash so the very first frame looks like the launch screen.
- **Languages**:
  - Start with **English + German** for UI + sentence content.
  - Other languages later (keep the data model ready).

## Branding (based on the icon)
- **Icon source**: copied into the Flutter project as `assets/brand/icon.png`.
- **Wordmark in-app (v1)**: text logo as `RichText` (text-only, no background, scales cleanly). Later can be replaced with a transparent PNG/SVG export if desired.
- **Look & feel**:
  - Rounded-square surfaces (icon-like), large corner radii.
  - Warm yellow gradient as the primary accent.
  - Matte near-black for primary text/icons (matching the thumb silhouette).
  - Soft ambient shadows (subtle depth, Apple-ish).
- **Design tokens**:
  - `brandYellow`: ~`#F4C542`
  - `brandYellowLight`: ~`#F9E27A`
  - `inkBlack`: ~`#1C1C1E`
  - `surfaceLight`: ~`#FAFAFA`
  - `surfaceDark`: ~`#121214`

## Project setup
- Flutter app lives at `/Users/abdisufi/Learn/Thumbs up V2/thumbs_up`.
- Project folder/name: `thumbs_up`
- App display name: **Thumbs Up**

## Folder structure (foundation)
Target `lib/` layout (example, not strict):

```text
lib/
  main.dart
  theme/        # AppTheme, colors, glass styles
    app_theme.dart
  navigation/   # App router (bottom nav later if we add tabs)
    app_router.dart
  screens/      # Launch/Home/Practice/Results pages (thin UI shells)
    launch_screen.dart
    home_screen.dart
    practice_screen.dart
    result_screen.dart
  models/       # Difficulty, typing session, session result
  typing/       # Ergonomic input listener, haptics, scoring helpers, Speed Stream engine
  lesson/       # Sentence/word loading, phrase stream formatting
  progress/     # Local best/results (later), history
  data/         # Phrase lists / packs (seeded from Tatoeba CC0)
  l10n/         # Localization ARB files (English + German)
```

## App flow & screens

### 1) Splash / Loading
- File: `lib/screens/launch_screen.dart`
- Show icon/wordmark prominently (centered) + title ("Thumbs Up"), with a subtle fade/scale.
- Auto-navigate to Home after ~2.8s.

**Launch sequence spec**
- Background: `LinearGradient` bottom → top: `#F4C542` → `#FCD34D`
- Logo (v1, text-only): `RichText`
  - "Thumbs " in brand yellow (`#F4C542`) with layered dark offset shadows (subtle 3D)
  - "Up" in matte black (`#121214`)
- Timing:
  - 0.0s → 1.2s: logo remains centered
  - 1.2s: logo animates upward (alignment Y to `-0.3`)
  - 1.5s: `CircularProgressIndicator` (matte black) fades in below the logo
  - 2.8s: smooth cross-fade route transition to `HomeScreen`

### 2) Home (difficulty select)
- File: `lib/screens/home_screen.dart`
- Three difficulty cards/buttons: Easy, Medium (Speed Stream), Pro (Speed Stream, faster).
- Selecting difficulty starts a session and navigates to Practice.
- Medium/Pro currently show a "coming soon" snackbar since Speed Stream isn't built yet.

### 3) Practice / Writing
- File: `lib/screens/practice_screen.dart`
- Layout:
  - **Phrase Stream** (target text) at the top: words separated by interpuncts (`·`), active word highlighted, upcoming words slightly faded.
  - **Easy** = static Phrase Stream. **Medium/Pro** = moving Phrase Stream ("Speed Stream").
  - Native keyboard input (no custom keyboard); small live stats row (time, WPM, accuracy).
- Input settings: `autocorrect: false`, `enableSuggestions: false`; cursor forced at end / selection disabled.
- Tracking:
  - Start timer on **first keystroke**.
  - Count a **mistake** whenever a newly typed character doesn't match the target character at that position.
  - **Easy**: finish when current input equals the target; navigate to Results.
  - **Medium/Pro (Speed Stream)**: finish when the timer ends; navigate to Results.

**Typing Surface Engine (core MVP loop)**
- Hidden/transparent `TextField` captures raw keypresses; autocorrect/suggestions/predictive disabled.
- Character-by-character matching: correct key → `#10B981` + light haptic; wrong key → `#F43F5E` + heavier haptic.
- Live HUD: WPM \( = (\text{correctChars}/5) / \text{minutes} \); accuracy = correct keys vs total keypresses (%).

### 4) Results
- File: `lib/screens/result_screen.dart`
- Shows WPM, accuracy, time, mistakes (and backspaces if tracked).
- Buttons: "Try again" (same difficulty, new phrase), "Home".

## Navigation (simple shell)
- File: `lib/navigation/app_router.dart` — centralizes routes/transitions for Launch → Home → Practice → Results, with a cross-fade for Launch → Home.

## Feature roadmap (selected add-ons: A,B,C,D,E,G,I,J)
To keep the build smooth, implement in this order (so timer/scoring stays correct):
- **After `practice-screen`**: A (Top bar Back/Home + Restart) + B (Confirm before leaving mid-run)
- **After `results-screen`**: C (Results actions: Next phrase, Repeat, Change difficulty)
- **Before saving "personal best"**: G (Pause/Resume) — affects elapsed time + WPM
- **After scoring is stable**: D (Local personal best per difficulty) + J (One-time onboarding tips)
- **After that**: E (Settings: haptics on/off, live HUD on/off, theme mode)
- **Later/content expansion**: I (Phrase packs/categories like punctuation & numbers)

## Medium/Pro: Dynamic Phrase Stream ("Speed Stream" / treadmill mode)

### UX spec
- **Easy**: Static Phrase Stream (no movement). Focus = accuracy.
- **Medium**: Speed Stream at a comfortable, learnable scroll speed.
- **Pro**: Speed Stream at a fast scroll speed (rhythm challenge).
- Speed values are simple constants, tuned after on-device prototyping.

**How it behaves**
- Horizontal strip near the top; words separated by interpuncts (`·`).
- Stream enters from the right, scrolls continuously left at constant speed.
- Player types the active word before it exits the left edge.
  - Typed correctly in time → mark **completed**, advance to next word.
  - Reaches left edge before completion → mark **missed**, drop, advance (run continues; no "game over").

**Run end**
- Speed Stream runs are **time-based** (default: **30s**). Later: optional 60s toggle.

### Scoring (Speed Stream)
- Track completed words, missed words, keystroke mistakes, elapsed time (pause/resume-safe).
- Results screen shows WPM + accuracy + missed words.

### Implementation approach (Flutter)
- **Engine** (`lib/typing/`): queue of word tokens with measured widths; advance via `Ticker` with delta time (`x -= speedPxPerSecond * dt`); mark missed/completed and advance accordingly.
- **Renderer**: clipped strip (`ClipRect`) + `CustomPainter` for stable 60fps; keep only a small window of tokens on screen (e.g. 10–25).
- **Input**: hidden `TextField` (autocorrect/suggestions off); compare input to active word; haptics on correct/incorrect keypress.

### Accessibility / motion safety
- "Reduce motion" option (later): falls back to Static Phrase Stream + timer.
- Don't rely on color only: underline/background cues for wrong chars/active word.

## Senior-dev checklist
- **Naming consistency**: final spelling in-app ("Thumbs Up") and package id.
- **Scoring rules**: mistakes counted when typed, even if later corrected.
- **Start/finish behavior**: start timer on first keystroke (default) vs "Tap to start".
- **Anti-cheat / input constraints**: keep cursor at end, disable paste/selection, single-line input.
- **Keep screen awake during a run**: prevents iOS/Android from dimming mid-exercise.
- **Accessibility**: don't rely only on color; support larger text sizes.
- **Native polish (optional later)**: launcher icons + native splash from brand assets.

## Data & logic
- Phrase source: `lib/data/easy_phrases_en.dart` — small hardcoded lists per difficulty, picked via `lib/lesson/phrase_deck.dart` (shuffle-once, no-repeat-until-exhausted).
- Session model + scoring: `lib/models/session_result.dart`, `lib/typing/wpm_calculator.dart`, `lib/typing/typing_engine.dart`, `lib/typing/char_status.dart`, `lib/typing/haptic_engine.dart`.
- State kept simple with `StatefulWidget` + a small in-memory session object (no heavy state management).

## Localization (English + German)
- UI strings to live in `.arb` files under `lib/l10n/` (English default + German translation).
- Default language: device locale; allow manual override in Settings.
- Phrase content is language-specific: `easy_en`, `easy_de`, etc.

## Sentence library
Goal: sentences that feel like real messages/jokes/snippets, not "AI-ish", with a large enough pool that repeats are rare.

- **Source strategy**: Tatoeba CC0 subset (`eng` + `deu`), filtered to "Easy" constraints. If CC0 volume is too small, switch to broader CC BY set + in-app attribution page.
- **Easy constraints**: short, conversational, mostly lowercase, minimal punctuation, no numbers yet; length ~15–60 characters; reject symbol-heavy/odd content.
- **Avoiding repeats**: shuffle-once deck per `(language, difficulty)`, persist current index later.
- **Licensing**: every external sentence source needs a clear license; CC BY content needs an "About / Credits" screen.

## UI style (minimal Apple-like)
- File: `lib/theme/app_theme.dart` — neutral backgrounds, large typography, generous padding, rounded corners; warm yellow accents + matte black text/icons + soft shadows.

**Theme tokens**
- Primary Brand Yellow: `Color(0xFFF4C542)`
- Sun-kissed Top Yellow Gradient: `Color(0xFFFCD34D)`
- Matte Black: `Color(0xFF121214)`
- Crisp Emerald (Correct Input): `Color(0xFF10B981)`
- Coral Rose (Typo/Error): `Color(0xFFF43F5E)`
- Canvas Light: `Color(0xFFFAFAFA)`
- Canvas Dark: `Color(0xFF1C1C1E)`

## Development workflow guardrails
These are captured as always-on Cursor rules now (see `.cursor/rules/flutter-dart-senior-standards.mdc` and the `ai-*.mdc` rules), so they don't need to be restated per-prompt. Key points kept here for reference:
- **No half-code**: every file change complete and runnable; no placeholders.
- **Keep files modular**: aim for ~150–200 lines max per file.
- **Terminal-first run/debug**: `flutter --version`, `flutter doctor`, `flutter devices`, `flutter run -d <deviceId>`.
- **PATH sanity**: confirm `which flutter` works in the terminal being used.
- **Workspace hygiene**: open only the app folder; avoid indexing heavy generated folders (`build/`, `.dart_tool/`, `ios/Pods/`, `android/.gradle/`).

## Later tweaks (keep this list so we don't forget)
- **Wordmark**: replace the `RichText` logo with a final wordmark asset (transparent PNG/SVG, no background) and pick the final typography.
- **Package/bundle id**: set a final reverse-DNS id before store release.
- **Speed Stream tuning**: tune scroll speeds after on-device testing; optionally add a 60s toggle.
- **Pro controls**: Timer on/off (endless Speed Stream when off) + user-adjustable scroll speed; persist in `SettingsStore` and wire into `SpeedStreamEngine(speedPxPerSecond:, runDuration:)` (constructor already accepts both; today Pro is fixed at 140 px/s / 30s).
- **Sentence library**: Everyday EN/DE Tatoeba pools ship as offline JSON (`assets/phrases/`); regenerate with `dart run tool/build_tatoeba_everyday.dart`. Still pending: German Punctuation pack, persist deck index, optional CC BY About screen polish.
- **Phrase packs**: consider persisting the last-picked category (like theme mode) and tracking personal bests per `(difficulty, category)` instead of difficulty alone.
- **Scoring + start UX**: revisit mistake/backspace rules after playtesting; decide if a short countdown or tap-to-start is wanted.
- **Accessibility**: add reduce-motion fallback for Speed Stream; color-blind safe cues; Dynamic Type sizing.
- **Native polish**: generate launcher icons + native splash from brand assets.
- **Languages**: add more languages beyond English/German later.

## Verification
- Run `flutter analyze`.
- Launch on iOS simulator and/or Android emulator to confirm:
  - keyboard pops reliably
  - timer/scoring works
  - navigation flow matches: Launch → Home → Practice → Results.

## Progress log (MVP build)

### Session 1
- **Note**: the workspace folder was renamed mid-build from `trying our curso` to `Thumbs up V2` (by the IDE/user). The Flutter project itself is unaffected; it now lives at `/Users/abdisufi/Learn/Thumbs up V2/thumbs_up`.
- **Done**:
  - Pre-flight checks (PATH, `flutter doctor`, `flutter devices`) — only a macOS desktop device is available locally; no iOS/Android simulator installed yet.
  - Created the Flutter project, copied the brand icon into `assets/brand/icon.png`, and set up the full `lib/` folder structure.
  - Implemented `AppTheme` (light + dark) with all brand tokens.
  - Implemented `Difficulty` + `SessionResult` models.
  - Implemented the typing engine (`TypingEngine`, `HapticEngine`, `WpmCalculator`, `CharStatus`) with keystroke-based matching, haptics, and live WPM/accuracy.
  - Added a starter Easy phrase list (20 placeholder EN sentences) + a `PhraseDeck` (shuffle-once, no-repeat-until-exhausted) picker.
  - Implemented `LaunchScreen` (gradient + RichText wordmark + timed sequence → cross-fade to Home), `HomeScreen` (3 difficulty cards; Medium/Pro show a "coming soon" snackbar since Speed Stream isn't built yet), `PracticeScreen` (static Phrase Stream, hidden input, live HUD, top bar Back/Restart, exit-confirm dialog), and `ResultScreen` (WPM/accuracy/mistakes/backspaces + Try Again/Home).
  - Wired `main.dart` to `AppTheme` + `LaunchScreen`; `flutter analyze` is clean; widget test passes; app boots and runs on macOS desktop with no crashes.
- **Not yet done (still pending from the todo list above)**:
  - Pause/Resume, local persistence (personal bests, settings, onboarding tips), phrase packs, localization (EN/DE), the full Tatoeba-based sentence library, and the Medium/Pro Speed Stream (treadmill) engine itself.
  - Results actions are currently "Try Again" + "Home" only (not yet "Next phrase / Repeat / Change difficulty" as 3 separate actions).
  - No native launcher icon / native splash generated yet (still using the in-app `LaunchScreen`).

### Session 2
- Fixed a pending-timer failure in `test/widget_test.dart`: the test now pumps 3 seconds after boot to flush the `LaunchScreen`'s spinner fade-in (1.5s) and delayed navigation to Home (2.8s) timers before the test completes. `flutter test` passes cleanly.
- Added this in-repo plan doc (`docs/PLAN.md`) plus an always-on Cursor rule (`.cursor/rules/thumbs-up-plan.mdc`) so the plan and progress log are automatically available at the start of every new session, instead of only living in Cursor's global, machine-local plans folder.

### Session 3
- Implemented the "Results actions" roadmap item (C): `ResultScreen` now shows **Next phrase** (new phrase, same difficulty), **Repeat** (same phrase again), and **Change difficulty** (returns to Home), replacing the old "Try Again"/"Home" pair.
- To support "Repeat", `PracticeScreen` gained an optional `initialPhrase` param (skips drawing a new phrase from the deck when set), and `AppRouter.replacePractice` was split into `AppRouter.nextPhrase` and `AppRouter.repeatPhrase`.
- `flutter analyze` is clean and `flutter test` passes after the change.
- Committed as `ef25d1d` ("Split Results screen into Next phrase / Repeat / Change difficulty actions").

### Session 4
- Implemented roadmap item G (Pause/Resume), the item the plan says must land **before** local personal-best persistence, since it affects elapsed time/WPM:
  - `TypingEngine` now tracks time with a `Stopwatch` instead of raw `DateTime`s, and gained `isPaused`, `pause()`, and `resume()`. `elapsed` freezes while paused and `onTextChanged` is a no-op during a pause, so keystrokes typed while paused can't leak into the run.
  - `PracticeTopBar` gained a pause/resume icon button (disabled until the run has started, hidden state once completed).
  - `PracticeScreen` wires this up: pausing unfocuses/disables the hidden input and shows a new `PracticePausedOverlay` (blocks the Phrase Stream from view + a "Resume" button); the 200ms tick timer skips rebuilding while paused.
- `flutter analyze` is clean, `flutter test` passes, and both files were formatted with `dart format`.
- Committed as `a2ad033` ("Add Pause/Resume to Practice runs").

### Session 5
- Implemented roadmap items D (local personal best per difficulty) + J (one-time onboarding tips), the next item after Pause/Resume. Added the `shared_preferences` dependency (`2.5.5`) to back both.
  - New `lib/progress/personal_best_store.dart`: `PersonalBest` + `PersonalBestStore.load/saveIfBest`, keyed per difficulty, comparing by WPM.
  - New `lib/progress/onboarding_store.dart` + `lib/screens/widgets/onboarding_tips_dialog.dart`: one-time "Got it" tips dialog, shown once on the first Home visit.
  - `PracticeScreen` now calls `PersonalBestStore.saveIfBest` on completion and forwards `isNewBest` through `AppRouter.toResult` to `ResultScreen`, which shows a small "New personal best" badge when true.
  - `HomeScreen` is now a `StatefulWidget`: loads each difficulty's best WPM (shown on `DifficultyCard` as a small "Best: N WPM" pill) and shows the onboarding dialog once.
  - `test/widget_test.dart` now calls `SharedPreferences.setMockInitialValues({})` before pumping, since Home reads prefs on init.
- Settings (E: haptics/HUD/theme toggles) intentionally stayed out of scope for this pass.
- `flutter analyze` is clean and `flutter test` passes.

### Session 6
- Implemented roadmap item E (Settings: haptics on/off, live HUD on/off, theme mode), the next item after personal bests/onboarding.
  - New `lib/progress/settings_store.dart`: `AppSettings` (immutable snapshot) + `SettingsStore`, a static store backed by `shared_preferences` that also exposes a `ValueNotifier<AppSettings>` (`SettingsStore.notifier`/`.current`) so widgets can either read the latest value synchronously or react live, without pulling in a state-management package.
  - `HapticEngine.correctKey`/`wrongKey` now check `SettingsStore.current.hapticsEnabled` before triggering feedback — this was already anticipated by that class's original doc comment.
  - `PracticeScreen` now hides the `LiveStatsRow` HUD entirely when `SettingsStore.current.hudEnabled` is false.
  - `main.dart`: `main()` is now `async`, calling `SettingsStore.load()` (persisted prefs) before `runApp`; `ThumbsUpApp` wraps `MaterialApp` in a `ValueListenableBuilder` on `SettingsStore.notifier` so changing the theme mode in Settings updates the whole app immediately.
  - New `lib/screens/settings_screen.dart`: a "Practice" section with two `SwitchListTile`s (haptics, HUD) and an "Appearance" section with a `SegmentedButton<ThemeMode>` (System/Light/Dark), all reading/writing through `SettingsStore`.
  - `HomeScreen` gained a settings gear `IconButton` next to the "Choose Your Challenge" header; `AppRouter.toSettings` pushes the new screen.
- `flutter analyze` is clean and `flutter test` passes. (Ran `dart format` too, but reverted the incidental reformatting it made to unrelated pre-existing files — a newer local `dart format` version changed their wrapping — to keep this session's diff scoped to the Settings feature.)

### Session 7
- Implemented roadmap item I (Phrase packs / categories), scoped down after confirming with the user: only two packs for now (**Everyday** = the existing list, **Punctuation & Numbers** = new), picked via chips on the Home screen, Easy-difficulty only (the data model is generic so Medium/Pro can reuse it once Speed Stream ships).
  - New `lib/models/phrase_category.dart`: `PhraseCategory` enum (`everyday`, `punctuationNumbers`) with `label`/`description`, mirroring `Difficulty`'s style.
  - New `lib/data/easy_phrases_punctuation_numbers_en.dart`: 20 starter Easy phrases that deliberately include digits/punctuation ($, %, times, dates, etc.), matching the tone/length of the existing list (and its "avoid apostrophes" convention, since Dart source uses single-quoted string literals).
  - New `lib/data/phrase_packs.dart`: `easyPhrasePacks`, a `Map<PhraseCategory, List<String>>` — the single place that maps a category to its phrase pool.
  - New `lib/screens/widgets/phrase_category_selector.dart`: a `ChoiceChip` row for picking the category, styled with the existing brand tokens.
  - `HomeScreen` now holds `_selectedCategory` state, renders `PhraseCategorySelector` above the difficulty list, and passes it into `AppRouter.toPractice`.
  - Threaded `PhraseCategory` through the run: `PracticeScreen` (new required `category` param, used to pick the deck's phrase pool), `TypingEngine.buildResult`, `SessionResult` (new `category` field), `AppRouter.nextPhrase`/`repeatPhrase` (new `category` param so "Next phrase"/"Repeat" keep using the same pack), and `ResultScreen` (now shows the category in its header line and forwards it to those actions).
  - Personal bests remain tracked per-difficulty only (not per-category) for now — noted under "Later tweaks" below if that's ever worth splitting out.
- `flutter analyze` is clean, `flutter test` passes, and the app boots on macOS desktop with no crashes (only local device available, as noted in Session 1).

### Session 8
- Implemented the Localization roadmap item, scoped down after confirming with the user: **UI strings only** (English + German), a **manual language picker in Settings** (defaults to device locale), using **Flutter's built-in `flutter gen-l10n` tooling** (no third-party i18n package). Phrase *content* stays English-only until the Tatoeba sentence-library task.
  - Added `flutter_localizations` (Flutter SDK) + `intl: ^0.20.2` to `pubspec.yaml`, enabled `generate: true`, and added `l10n.yaml` (arb-dir `lib/l10n`, output to `lib/l10n/generated`, non-synthetic — `synthetic-package` is deprecated/removed as of this Flutter version). Added `/lib/l10n/generated/` to `.gitignore` since `flutter gen-l10n` regenerates it on every `pub get`/run/build.
  - New `lib/l10n/app_en.arb` (template) + `lib/l10n/app_de.arb`: every user-facing string in the app (Home, Settings, onboarding dialog, live HUD labels, Results, Practice's exit-confirm dialog, the paused overlay, difficulty/category labels+descriptions, snackbar/badge copy), including three ICU placeholders (`comingSoonSnackbar`, `difficultyBestWpm`, `resultSummaryLine`).
  - `Difficulty` and `PhraseCategory` (`lib/models/`): `label`/`subtitle`/`description` changed from plain getters to methods taking `AppLocalizations l10n`, since they now need to reflect the chosen language. Updated every call site (`DifficultyCard`, `PhraseCategorySelector`, `HomeScreen`, `PracticeScreen`, `ResultScreen`).
  - `lib/progress/settings_store.dart`: `AppSettings` gained a `locale` field (`Locale?`, null = follow device locale) + `SettingsStore.setLocale`; persisted as `'system'/'en'/'de'`.
  - `lib/main.dart`: `MaterialApp` now wires `localizationsDelegates`/`supportedLocales`/`locale` (from `SettingsStore`) and uses `onGenerateTitle` for the window/task-switcher title.
  - `lib/screens/settings_screen.dart`: new "Language" section with a `SegmentedButton<Locale?>` (System/English/German), same visual style as the existing theme-mode selector.
  - Swapped every remaining hardcoded `Text('...')`/dialog/snackbar/tooltip string across `HomeScreen`, `DifficultyCard`, `PhraseCategorySelector`, `OnboardingTipsDialog`, `LiveStatsRow`, `ResultScreen`, `PracticeScreen` (exit-confirm dialog + top bar title), and `PracticePausedOverlay` for `AppLocalizations.of(context)` lookups.
- `flutter analyze` is clean, `flutter test` passes, and the app boots on macOS desktop with no crashes.

### Session 9
- Implemented Medium/Pro **Speed Stream** (treadmill mode) and parked the Tatoeba sentence library under Later tweaks as the next content milestone.
  - **Later tweaks**: expanded the sentence-library bullet to explicitly name Tatoeba CC0 EN/DE filtering, CC BY fallback + About/Credits, and persisted deck index.
  - New `lib/lesson/word_deck.dart`: flattens category phrase packs into words, shuffle-once, auto-refills for endless 30s runs.
  - New `lib/typing/speed_stream_engine.dart`: token queue with measured widths; `tick(dt)` scrolls left at Medium `80` / Pro `140` px/s; complete vs miss; pause/resume; ends after 30s from first keystroke; builds `SessionResult` with `completedWords`/`missedWords`.
  - New `lib/screens/widgets/speed_stream_view.dart`: clipped strip + `CustomPainter` (interpuncts, active-word char statuses with underline cues).
  - `SessionResult`: added `completedWords`/`missedWords` + `isSpeedStream` helper.
  - `PracticeScreen`: branches Easy (`TypingEngine` + `PhraseStreamView`) vs Medium/Pro (`SpeedStreamEngine` + `Ticker` + `SpeedStreamView`); HUD shows remaining time for stream runs.
  - `Difficulty.isAvailable` is always true; Home no longer shows the "coming soon" snackbar.
  - `ResultScreen`: stream runs show Completed/Missed (+ mistakes/backspaces); primary action is "Play again" (same difficulty+category); Easy keeps Next phrase / Repeat.
  - Localized new strings (`statsTimeLeft`, `resultStatCompleted`, `resultStatMissed`, `resultPlayAgain`) in EN/DE ARBs.
- `flutter analyze` is clean, `flutter test` passes, and the app boots on macOS desktop with no crashes.

### Session 10
- Implemented the Tatoeba **sentence library** for Everyday EN/DE (offline assets), scoped 1A/2A/3A.
  - New `tool/build_tatoeba_everyday.dart`: downloads Tatoeba per-language exports, filters (15–60 chars, no digits, limited punctuation, lowercased), caps at 800/lang, writes `assets/phrases/everyday_{en,de}.json` + `manifest.json`. EN uses CC0; DE CC0 was only ~46 sentences so the script falls back to the full DE export (**CC BY 2.0 FR**) and records that in the manifest.
  - Registered phrase assets in `pubspec.yaml`; cache dir `tool/.tatoeba_cache/` gitignored.
  - New `lib/data/phrase_pack_resolver.dart`: loads/caches JSON via `rootBundle`; Everyday language follows UI locale (`de` → DE, else EN); Punctuation & Numbers stays hand-written EN; soft-fallback to `easy_phrases_en.dart` if an asset fails.
  - `main.dart` prefetches Everyday packs after `SettingsStore.load()`; `PracticeScreen` uses `PhrasePackResolver.phrases` (incl. Restart).
  - Settings Credits one-liner (localized) attributing Tatoeba EN CC0 / DE CC BY.
- `flutter analyze` is clean, `flutter test` passes.

### Session 11
- Closed the last MVP checklist item: **difficulty-tiered Speed Stream word pools** (content harder, scoring formulas unchanged).
  - New `lib/lesson/difficulty_word_filter.dart`: Medium keeps words length ≥ 4, Pro ≥ 6; falls back to the full flatten if fewer than 40 words remain.
  - `WordDeck`: exposed `flatten` + `fromWords` constructor so Practice can pass a pre-filtered list.
  - `PracticeScreen` Speed Stream init/restart now builds `WordDeck.fromWords(DifficultyWordFilter.wordsForDifficulty(...))`; Easy phrase path unchanged.
- `flutter analyze` is clean, `flutter test` passes.

### Session 12
- Fixed a crash on cold-launching a Medium/Pro (Speed Stream) run: the hidden capture `TextField` in `PracticeScreen` computed `maxLength` as `_streamEngine?.activeWord.length ?? 32`, but `SpeedStreamEngine.activeWord` returns `''` (length `0`, not `null`) until `SpeedStreamView` seeds its tokens via a post-frame callback — so the very first synchronous build hit Flutter's `maxLength > 0` assertion and threw. Hot reload/hot restart could mask this by reusing already-seeded engine state from a prior run, which is why it looked intermittent ("worked an hour ago").
  - Changed the `maxLength` expression to fall back to `32` whenever `activeWord` is empty (not only when the engine itself is null).
- `flutter analyze` is clean and `flutter test` passes.

### Session 13
- Post-MVP polish Schritt 1: Live HUD (Zeit/WPM/Genauigkeit) in `live_stats_row.dart` uses yellow badges (`brandYellow` @ 0.9, radius 16, matteBlack text) matching Home difficulty letter tiles — readable in Dark Mode.
- Parked Schritt 4 (Pro timer on/off + adjustable Speed Stream speed) under Later tweaks; added Post-MVP checklist section.
- `flutter analyze` is clean and `flutter test` passes.

### Session 14
- Post-MVP polish Schritt 2: hardened Easy → Results navigation in `practice_screen.dart`.
  - Schedule `_goToResult` via post-frame callback (avoid navigating inside the text listener).
  - Prefer Results even if `PersonalBestStore.saveIfBest` throws; reset `_navigatedToResult` if navigation itself fails so the user isn't stuck.
  - Remove Easy `TextField.maxLength` (engine already truncates) so IME composition can't drop the final key.
- Medium/Pro path unchanged aside from sharing the safer `_goToResult`.
- `dart analyze` / `flutter test` pass.

### Session 15
- Post-MVP polish Schritt 3: Easy is now a **30s phrase loop**.
  - `TypingEngine`: timed `runDuration` (30s), `isPhraseComplete` / `loadNextPhrase` / `finishRun` / `remaining`; stats accumulate across phrases; Results only after timeout.
  - `PracticeScreen`: phrase complete advances + clears input; HUD shows countdown; timeout → Results.
  - New `AnimatedPhraseStreamView`: old phrase slides up, new phrase enters from below.
  - `ResultScreen`: Easy uses Play again (like Medium/Pro); EN/DE Easy description updated.
- Medium/Pro Speed Stream untouched.
- `dart analyze` / `flutter test` pass.
