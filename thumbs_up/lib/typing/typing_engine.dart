import 'package:flutter/foundation.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/phrase_category.dart';
import 'package:thumbs_up/models/session_result.dart';
import 'package:thumbs_up/typing/char_status.dart';
import 'package:thumbs_up/typing/haptic_engine.dart';
import 'package:thumbs_up/typing/wpm_calculator.dart';

/// Drives the Easy-mode Phrase Stream typing loop (30s timed run).
///
/// Responsibilities:
/// - Starts the timer on the first keystroke.
/// - Compares typed input to [targetPhrase] character-by-character.
/// - Counts mistakes (wrong key typed, even if later corrected) and
///   backspaces (tracked separately, do not reduce the mistake count).
/// - On phrase match: exposes [isPhraseComplete] so the UI can advance to
///   the next phrase without ending the run.
/// - Ends the run when [finishRun] is called (typically after [hasTimedOut]).
/// - Supports pausing: [elapsed] stops advancing while [isPaused], and
///   input is expected to be ignored by the caller during a pause.
class TypingEngine extends ChangeNotifier {
  TypingEngine({
    required String this._targetPhrase,
    this.haptics = const HapticEngine(),
    this.runDuration = const Duration(seconds: 30),
  });

  final HapticEngine haptics;

  /// Active (unpaused) length of an Easy run from the first keystroke.
  final Duration runDuration;

  String _targetPhrase;
  final Stopwatch _stopwatch = Stopwatch();
  String _typed = '';
  int _mistakes = 0;
  int _backspaces = 0;
  int _priorCorrectChars = 0;
  bool _started = false;
  bool _paused = false;
  bool _completed = false;

  String get targetPhrase => _targetPhrase;
  String get typed => _typed;
  bool get isStarted => _started;
  bool get isPaused => _paused;

  /// True when the full 30s run has been finished via [finishRun].
  bool get completed => _completed;

  /// True when the current phrase is fully typed (exact match).
  bool get isPhraseComplete =>
      _typed.isNotEmpty && _typed == _targetPhrase && !_completed;

  bool get hasTimedOut => _started && elapsed >= runDuration;

  int get mistakes => _mistakes;
  int get backspaces => _backspaces;

  /// Time since the first keystroke, excluding any paused duration.
  Duration get elapsed => _stopwatch.elapsed;

  Duration get remaining {
    final left = runDuration - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  int get correctCharsTyped {
    var count = _priorCorrectChars;
    for (var i = 0; i < _typed.length && i < _targetPhrase.length; i++) {
      if (_typed[i] == _targetPhrase[i]) count++;
    }
    return count;
  }

  double get liveWpm =>
      WpmCalculator.wpm(correctChars: correctCharsTyped, elapsed: elapsed);

  double get liveAccuracy => WpmCalculator.accuracyPercent(
    correctChars: correctCharsTyped,
    mistakes: _mistakes,
  );

  /// Call whenever the hidden input field's text changes.
  void onTextChanged(String newText) {
    if (_completed || _paused) return;

    if (newText.length > _targetPhrase.length) {
      newText = newText.substring(0, _targetPhrase.length);
    }

    if (!_started && newText.isNotEmpty) {
      _started = true;
      _stopwatch.start();
    }

    if (newText.length > _typed.length) {
      final index = newText.length - 1;
      final typedChar = newText[index];
      final isCorrect =
          index < _targetPhrase.length && typedChar == _targetPhrase[index];
      if (isCorrect) {
        haptics.correctKey();
      } else {
        _mistakes++;
        haptics.wrongKey();
      }
    } else if (newText.length < _typed.length) {
      _backspaces++;
    }

    _typed = newText;
    notifyListeners();
  }

  /// Fold the finished phrase into cumulative stats and start [next].
  /// Keeps the stopwatch and mistake/backspace totals running.
  void loadNextPhrase(String next) {
    if (_completed) return;

    var currentCorrect = 0;
    for (var i = 0; i < _typed.length && i < _targetPhrase.length; i++) {
      if (_typed[i] == _targetPhrase[i]) currentCorrect++;
    }
    _priorCorrectChars += currentCorrect;
    _targetPhrase = next;
    _typed = '';
    notifyListeners();
  }

  /// Marks the timed run finished and freezes [elapsed].
  void finishRun() {
    if (_completed) return;
    _completed = true;
    _stopwatch.stop();
    notifyListeners();
  }

  /// Pauses the run: freezes [elapsed] and blocks further [onTextChanged]
  /// calls until [resume] is called. No-op if not started, already
  /// completed, or already paused.
  void pause() {
    if (!_started || _completed || _paused) return;
    _paused = true;
    _stopwatch.stop();
    notifyListeners();
  }

  /// Resumes a paused run, continuing [elapsed] from where it left off.
  void resume() {
    if (!_paused) return;
    _paused = false;
    _stopwatch.start();
    notifyListeners();
  }

  /// Resets the engine so the same phrase (or a new one via a fresh
  /// instance) can be retried.
  void reset() {
    _typed = '';
    _mistakes = 0;
    _backspaces = 0;
    _priorCorrectChars = 0;
    _started = false;
    _paused = false;
    _completed = false;
    _stopwatch
      ..stop()
      ..reset();
    notifyListeners();
  }

  /// Per-character render status for the Phrase Stream widget.
  List<CharStatus> buildCharStatuses() {
    return List<CharStatus>.generate(_targetPhrase.length, (i) {
      if (i < _typed.length) {
        return _typed[i] == _targetPhrase[i]
            ? CharStatus.correct
            : CharStatus.incorrect;
      }
      if (i == _typed.length) return CharStatus.cursor;
      return CharStatus.pending;
    });
  }

  SessionResult buildResult(Difficulty difficulty, PhraseCategory category) {
    final capped = elapsed > runDuration ? runDuration : elapsed;
    return SessionResult(
      difficulty: difficulty,
      category: category,
      phrase: _targetPhrase,
      elapsed: capped,
      correctChars: correctCharsTyped,
      mistakes: _mistakes,
      backspaces: _backspaces,
    );
  }
}
