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
- [ ] Practice controls — **partially done**: top bar Back/Restart + exit-confirm dialog are in; Pause/Resume (with correct timer handling) is still pending
- [x] Results actions: Next phrase / Repeat / Change difficulty
- [ ] Local persistence (personal best per difficulty, settings, one-time onboarding tips)
- [ ] Phrase packs / categories (e.g. punctuation & numbers mode)
- [ ] Localization (English + German UI strings + language selector)
- [ ] Sentence library (Tatoeba-based, large EN/DE pool, filtered + attributed)
- [ ] Medium/Pro "Speed Stream" (treadmill) mode + scoring, speed tuned on-device
- [ ] Phrase lists + scoring logic per difficulty (beyond the Easy starter list)
- [x] Verification: `flutter analyze` clean, widget test passes, app boots/runs

## Assumptions (to keep it simple)
- We'll build with **Flutter** and target **iOS + Android**.
- **Easy**: one run = **one phrase**; user can replay to get a new phrase.
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
- **Sentence library**: expand and refine filters/packs so sentences feel human; persist the "deck index" so repeats stay rare.
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
