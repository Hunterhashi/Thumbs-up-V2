import 'package:flutter/foundation.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/session_result.dart';
import 'package:thumbs_up/typing/char_status.dart';
import 'package:thumbs_up/typing/haptic_engine.dart';
import 'package:thumbs_up/typing/wpm_calculator.dart';

/// Drives the Easy-mode (static Phrase Stream) typing loop.
///
/// Responsibilities:
/// - Starts the timer on the first keystroke.
/// - Compares typed input to [targetPhrase] character-by-character.
/// - Counts mistakes (wrong key typed, even if later corrected) and
///   backspaces (tracked separately, do not reduce the mistake count).
/// - Exposes live WPM/accuracy and completion state.
class TypingEngine extends ChangeNotifier {
  TypingEngine({
    required this.targetPhrase,
    this.haptics = const HapticEngine(),
  });

  final String targetPhrase;
  final HapticEngine haptics;

  String _typed = '';
  int _mistakes = 0;
  int _backspaces = 0;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _completed = false;

  String get typed => _typed;
  bool get isStarted => _startTime != null;
  bool get completed => _completed;
  int get mistakes => _mistakes;
  int get backspaces => _backspaces;

  /// Time since the first keystroke. Keeps ticking until [completed].
  Duration get elapsed {
    if (_startTime == null) return Duration.zero;
    final end = _endTime ?? DateTime.now();
    return end.difference(_startTime!);
  }

  int get correctCharsTyped {
    var count = 0;
    for (var i = 0; i < _typed.length && i < targetPhrase.length; i++) {
      if (_typed[i] == targetPhrase[i]) count++;
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
    if (_completed) return;

    if (newText.length > targetPhrase.length) {
      newText = newText.substring(0, targetPhrase.length);
    }

    _startTime ??= newText.isNotEmpty ? DateTime.now() : null;

    if (newText.length > _typed.length) {
      final index = newText.length - 1;
      final typedChar = newText[index];
      final isCorrect =
          index < targetPhrase.length && typedChar == targetPhrase[index];
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

    if (_typed == targetPhrase) {
      _completed = true;
      _endTime = DateTime.now();
    }

    notifyListeners();
  }

  /// Resets the engine so the same phrase (or a new one via a fresh
  /// instance) can be retried.
  void reset() {
    _typed = '';
    _mistakes = 0;
    _backspaces = 0;
    _startTime = null;
    _endTime = null;
    _completed = false;
    notifyListeners();
  }

  /// Per-character render status for the Phrase Stream widget.
  List<CharStatus> buildCharStatuses() {
    return List<CharStatus>.generate(targetPhrase.length, (i) {
      if (i < _typed.length) {
        return _typed[i] == targetPhrase[i]
            ? CharStatus.correct
            : CharStatus.incorrect;
      }
      if (i == _typed.length) return CharStatus.cursor;
      return CharStatus.pending;
    });
  }

  SessionResult buildResult(Difficulty difficulty) {
    return SessionResult(
      difficulty: difficulty,
      phrase: targetPhrase,
      elapsed: elapsed,
      correctChars: correctCharsTyped,
      mistakes: _mistakes,
      backspaces: _backspaces,
    );
  }
}
