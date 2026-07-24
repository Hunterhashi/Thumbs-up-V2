import 'package:flutter/foundation.dart';
import 'package:thumbs_up/lesson/word_deck.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/phrase_category.dart';
import 'package:thumbs_up/models/session_result.dart';
import 'package:thumbs_up/typing/char_status.dart';
import 'package:thumbs_up/typing/haptic_engine.dart';
import 'package:thumbs_up/typing/wpm_calculator.dart';

/// A single word on the Speed Stream strip.
class StreamToken {
  StreamToken({required this.word, required this.width, required this.x});

  final String word;
  final double width;

  /// Left edge of the word in strip coordinates (0 = left clip edge).
  double x;

  double get right => x + width;
}

/// Drives Medium/Pro "Speed Stream" (treadmill) runs.
///
/// Words scroll continuously left. The player must finish the active word
/// before its left edge exits the strip; otherwise it counts as missed and
/// the run continues. The run ends after [runDuration] of active (unpaused)
/// time from the first keystroke.
class SpeedStreamEngine extends ChangeNotifier {
  SpeedStreamEngine({
    required WordDeck wordDeck,
    required this.speedPxPerSecond,
    this.haptics = const HapticEngine(),
    this.runDuration = const Duration(seconds: 30),
    this.gapPx = 28,
    this.targetVisibleTokens = 12,
  }) : _deck = wordDeck;

  static double speedFor(Difficulty difficulty) => switch (difficulty) {
    Difficulty.medium => 80,
    Difficulty.pro => 140,
    Difficulty.easy => 80,
  };

  final WordDeck _deck;
  final double speedPxPerSecond;
  final HapticEngine haptics;
  final Duration runDuration;
  final double gapPx;
  final int targetVisibleTokens;

  final Stopwatch _stopwatch = Stopwatch();
  final List<StreamToken> _tokens = [];

  String _typed = '';
  int _mistakes = 0;
  int _backspaces = 0;
  int _correctChars = 0;
  int _completedWords = 0;
  int _missedWords = 0;
  bool _started = false;
  bool _paused = false;
  bool _completed = false;
  bool _needsInputClear = false;
  double _viewportWidth = 0;
  double Function(String word)? _measureWidth;

  List<StreamToken> get tokens => List.unmodifiable(_tokens);
  String get typed => _typed;
  String get activeWord => _tokens.isEmpty ? '' : _tokens.first.word;
  bool get isStarted => _started;
  bool get isPaused => _paused;
  bool get completed => _completed;
  int get mistakes => _mistakes;
  int get backspaces => _backspaces;
  int get completedWords => _completedWords;
  int get missedWords => _missedWords;
  Duration get elapsed => _stopwatch.elapsed;

  Duration get remaining {
    final left = runDuration - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  double get liveWpm =>
      WpmCalculator.wpm(correctChars: _correctChars, elapsed: elapsed);

  double get liveAccuracy => WpmCalculator.accuracyPercent(
    correctChars: _correctChars,
    mistakes: _mistakes,
  );

  /// Bind a width-measuring callback and the strip's layout width, then
  /// seed the initial token window. Call from the view after first layout.
  void configure({
    required double viewportWidth,
    required double Function(String word) measureWidth,
  }) {
    final widthChanged = (_viewportWidth - viewportWidth).abs() > 0.5;
    _viewportWidth = viewportWidth;
    _measureWidth = measureWidth;
    if (_tokens.isEmpty) {
      _seedTokens();
      notifyListeners();
    } else if (widthChanged) {
      notifyListeners();
    }
  }

  void _seedTokens() {
    final measure = _measureWidth;
    if (measure == null || _viewportWidth <= 0) return;

    var x = _viewportWidth * 0.18;
    while (_tokens.length < targetVisibleTokens) {
      final word = _deck.next();
      final width = measure(word);
      _tokens.add(StreamToken(word: word, width: width, x: x));
      x += width + gapPx;
    }
  }

  void _ensureTokenWindow() {
    final measure = _measureWidth;
    if (measure == null || _viewportWidth <= 0) return;

    while (_tokens.length < targetVisibleTokens) {
      final word = _deck.next();
      final width = measure(word);
      final startX = _tokens.isEmpty
          ? _viewportWidth * 0.18
          : _tokens.last.right + gapPx;
      // Keep new words at or past the right edge so they enter from the right.
      final x = startX < _viewportWidth ? _viewportWidth + gapPx : startX;
      _tokens.add(StreamToken(word: word, width: width, x: x));
    }
  }

  /// Advance scroll by [dt] seconds. No-op until started, while paused, or
  /// after the run completes.
  void tick(double dt) {
    if (!_started || _paused || _completed || dt <= 0) return;

    final dx = speedPxPerSecond * dt;
    for (final token in _tokens) {
      token.x -= dx;
    }

    // Miss (Variant A): active word's left edge reached/passed the clip.
    // Pixel scroll position is independent of typed-char indexing; on miss
    // we reset typed state so the next word starts clean.
    while (_tokens.isNotEmpty && _tokens.first.x <= 0) {
      _missActiveWord();
    }

    _ensureTokenWindow();

    if (elapsed >= runDuration) {
      _finish();
    } else {
      notifyListeners();
    }
  }

  void _missActiveWord() {
    if (_tokens.isEmpty) return;
    final word = _tokens.first.word;
    final remaining = word.length - _typed.length;
    if (remaining > 0) {
      _mistakes += remaining;
    }
    _missedWords++;
    _typed = '';
    _needsInputClear = true;
    _tokens.removeAt(0);
    _ensureTokenWindow();
  }

  void _completeActiveWord() {
    if (_tokens.isEmpty) return;
    _completedWords++;
    _correctChars += _tokens.first.word.length;
    _typed = '';
    _needsInputClear = true;
    _tokens.removeAt(0);
    _ensureTokenWindow();
  }

  /// Whether the hidden input should be cleared (after miss or complete).
  /// Consuming resets the flag so each clear is requested once.
  bool takeNeedsInputClear() {
    if (!_needsInputClear) return false;
    _needsInputClear = false;
    return true;
  }

  /// Call whenever the hidden input field's text changes.
  /// Returns true when the active word was just completed (caller should
  /// clear the text field).
  bool onTextChanged(String newText) {
    if (_completed || _paused || _tokens.isEmpty) return false;

    final target = _tokens.first.word;
    if (newText.length > target.length) {
      newText = newText.substring(0, target.length);
    }

    if (!_started && newText.isNotEmpty) {
      _started = true;
      _stopwatch.start();
    }

    if (newText.length > _typed.length) {
      final index = newText.length - 1;
      final typedChar = newText[index];
      final isCorrect = index < target.length && typedChar == target[index];
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

    var cleared = false;
    if (_typed == target) {
      _completeActiveWord();
      cleared = true;
    }

    if (elapsed >= runDuration) {
      _finish();
    } else {
      notifyListeners();
    }
    return cleared;
  }

  void pause() {
    if (!_started || _completed || _paused) return;
    _paused = true;
    _stopwatch.stop();
    notifyListeners();
  }

  void resume() {
    if (!_paused) return;
    _paused = false;
    _stopwatch.start();
    notifyListeners();
  }

  void _finish() {
    if (_completed) return;
    _completed = true;
    _paused = false;
    _stopwatch.stop();
    notifyListeners();
  }

  List<CharStatus> buildActiveCharStatuses() {
    final target = activeWord;
    return List<CharStatus>.generate(target.length, (i) {
      if (i < _typed.length) {
        return _typed[i] == target[i]
            ? CharStatus.correct
            : CharStatus.incorrect;
      }
      if (i == _typed.length) return CharStatus.cursor;
      return CharStatus.pending;
    });
  }

  SessionResult buildResult(Difficulty difficulty, PhraseCategory category) {
    return SessionResult(
      difficulty: difficulty,
      category: category,
      phrase: 'Speed Stream',
      elapsed: elapsed > runDuration ? runDuration : elapsed,
      correctChars: _correctChars,
      mistakes: _mistakes,
      backspaces: _backspaces,
      completedWords: _completedWords,
      missedWords: _missedWords,
    );
  }
}
