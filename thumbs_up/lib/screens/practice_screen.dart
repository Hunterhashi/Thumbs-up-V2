import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:thumbs_up/data/phrase_pack_resolver.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/lesson/phrase_deck.dart';
import 'package:thumbs_up/lesson/word_deck.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/models/phrase_category.dart';
import 'package:thumbs_up/navigation/app_router.dart';
import 'package:thumbs_up/progress/personal_best_store.dart';
import 'package:thumbs_up/progress/settings_store.dart';
import 'package:thumbs_up/screens/widgets/live_stats_row.dart';
import 'package:thumbs_up/screens/widgets/phrase_stream_view.dart';
import 'package:thumbs_up/screens/widgets/practice_paused_overlay.dart';
import 'package:thumbs_up/screens/widgets/practice_top_bar.dart';
import 'package:thumbs_up/screens/widgets/speed_stream_view.dart';
import 'package:thumbs_up/typing/speed_stream_engine.dart';
import 'package:thumbs_up/typing/typing_engine.dart';

/// The typing test itself: Easy uses a static Phrase Stream; Medium/Pro use
/// the scrolling Speed Stream treadmill.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.difficulty,
    required this.category,
    this.initialPhrase,
  });

  final Difficulty difficulty;

  /// Which phrase pack to draw from (see `PhrasePackResolver`).
  final PhraseCategory category;

  /// When set on Easy runs, starts with this exact phrase (Results "Repeat").
  /// Ignored for Speed Stream runs.
  final String? initialPhrase;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen>
    with SingleTickerProviderStateMixin {
  late final bool _isSpeedStream;
  PhraseDeck? _phraseDeck;
  TypingEngine? _easyEngine;
  SpeedStreamEngine? _streamEngine;
  Ticker? _streamTicker;
  Duration _lastTickElapsed = Duration.zero;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _hudTimer;
  bool _navigatedToResult = false;

  bool get _isPaused => _isSpeedStream
      ? (_streamEngine?.isPaused ?? false)
      : (_easyEngine?.isPaused ?? false);

  bool get _isStarted => _isSpeedStream
      ? (_streamEngine?.isStarted ?? false)
      : (_easyEngine?.isStarted ?? false);

  bool get _isCompleted => _isSpeedStream
      ? (_streamEngine?.completed ?? false)
      : (_easyEngine?.completed ?? false);

  @override
  void initState() {
    super.initState();
    _isSpeedStream = widget.difficulty != Difficulty.easy;
    final phrases = PhrasePackResolver.phrases(widget.category);

    if (_isSpeedStream) {
      _streamEngine = SpeedStreamEngine(
        wordDeck: WordDeck(phrases),
        speedPxPerSecond: SpeedStreamEngine.speedFor(widget.difficulty),
      );
      _streamEngine!.addListener(_onStreamChanged);
      _streamTicker = createTicker(_onStreamTick);
      _streamTicker!.start();
    } else {
      _phraseDeck = PhraseDeck(phrases);
      _easyEngine = TypingEngine(
        targetPhrase: widget.initialPhrase ?? _phraseDeck!.next(),
      );
      _hudTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted &&
            (_easyEngine?.isStarted ?? false) &&
            !(_easyEngine?.completed ?? true) &&
            !(_easyEngine?.isPaused ?? true)) {
          setState(() {});
        }
      });
    }

    _controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _streamEngine?.removeListener(_onStreamChanged);
    _streamTicker?.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _hudTimer?.cancel();
    _streamEngine?.dispose();
    _easyEngine?.dispose();
    super.dispose();
  }

  void _onStreamTick(Duration elapsed) {
    final engine = _streamEngine;
    if (engine == null) return;
    final dt = (elapsed - _lastTickElapsed).inMicroseconds / 1e6;
    _lastTickElapsed = elapsed;
    if (dt > 0 && dt < 0.25) {
      engine.tick(dt);
    }
  }

  void _onStreamChanged() {
    if (!mounted) return;
    if (_streamEngine?.completed == true && !_navigatedToResult) {
      _goToResult();
    } else {
      setState(() {});
    }
  }

  void _onControllerChanged() {
    if (_isSpeedStream) {
      final engine = _streamEngine;
      if (engine == null) return;
      final cleared = engine.onTextChanged(_controller.text);
      if (cleared && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    } else {
      final engine = _easyEngine;
      if (engine == null) return;
      engine.onTextChanged(_controller.text);
      if (engine.completed && !_navigatedToResult) {
        _goToResult();
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _goToResult() async {
    if (_navigatedToResult) return;
    _navigatedToResult = true;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final result = _isSpeedStream
        ? _streamEngine!.buildResult(widget.difficulty, widget.category)
        : _easyEngine!.buildResult(widget.difficulty, widget.category);
    final isNewBest = await PersonalBestStore.saveIfBest(result);
    if (!mounted) return;
    AppRouter.toResult(context, result, isNewBest: isNewBest);
  }

  void _restart() {
    final phrases = PhrasePackResolver.phrases(
      widget.category,
      uiLocale: Localizations.localeOf(context),
    );
    setState(() {
      _controller.clear();
      _navigatedToResult = false;
      if (_isSpeedStream) {
        _streamEngine?.removeListener(_onStreamChanged);
        _streamEngine?.dispose();
        _lastTickElapsed = Duration.zero;
        _streamEngine = SpeedStreamEngine(
          wordDeck: WordDeck(phrases),
          speedPxPerSecond: SpeedStreamEngine.speedFor(widget.difficulty),
        );
        _streamEngine!.addListener(_onStreamChanged);
      } else {
        _phraseDeck = PhraseDeck(phrases);
        _easyEngine = TypingEngine(targetPhrase: _phraseDeck!.next());
      }
    });
    _focusNode.requestFocus();
  }

  void _togglePause() {
    if (_isSpeedStream) {
      final engine = _streamEngine!;
      if (engine.isPaused) {
        engine.resume();
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
        engine.pause();
      }
    } else {
      final engine = _easyEngine!;
      if (engine.isPaused) {
        engine.resume();
        setState(() {});
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
        setState(() {
          engine.pause();
        });
      }
    }
  }

  Future<bool> _confirmExitIfNeeded() async {
    final inProgress = _isStarted && !_isCompleted;
    if (!inProgress) return true;

    final l10n = AppLocalizations.of(context);
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitDialogTitle),
        content: Text(l10n.exitDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.exitDialogKeepTyping),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.exitDialogLeave),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  void _onBack(BuildContext context) async {
    final canLeave = await _confirmExitIfNeeded();
    if (!canLeave || !context.mounted) return;
    AppRouter.toHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = _isPaused;
    final canTogglePause = _isStarted && !_isCompleted;
    final l10n = AppLocalizations.of(context);

    final double wpm;
    final double accuracy;
    final Duration timeValue;
    final bool showRemaining;
    if (_isSpeedStream) {
      final engine = _streamEngine!;
      wpm = engine.liveWpm;
      accuracy = engine.liveAccuracy;
      timeValue = engine.isStarted ? engine.remaining : engine.runDuration;
      showRemaining = true;
    } else {
      final engine = _easyEngine!;
      wpm = engine.liveWpm;
      accuracy = engine.liveAccuracy;
      timeValue = engine.elapsed;
      showRemaining = false;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final canLeave = await _confirmExitIfNeeded();
        if (!canLeave || !context.mounted) return;
        Navigator.of(context).pop();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isPaused) _focusNode.requestFocus();
        },
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      PracticeTopBar(
                        title: widget.difficulty.label(l10n),
                        onBack: () => _onBack(context),
                        onRestart: _restart,
                        isPaused: isPaused,
                        onPauseResume: canTogglePause ? _togglePause : null,
                      ),
                      if (SettingsStore.current.hudEnabled) ...[
                        const SizedBox(height: 12),
                        LiveStatsRow(
                          elapsed: timeValue,
                          wpm: wpm,
                          accuracyPercent: accuracy,
                          showAsRemaining: showRemaining,
                        ),
                      ],
                      Expanded(
                        child: Center(
                          child: _isSpeedStream
                              ? SpeedStreamView(engine: _streamEngine!)
                              : PhraseStreamView(
                                  phrase: _easyEngine!.targetPhrase,
                                  statuses: _easyEngine!.buildCharStatuses(),
                                ),
                        ),
                      ),
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          height: 1,
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: !isPaused,
                            autocorrect: false,
                            enableSuggestions: false,
                            enableIMEPersonalizedLearning: false,
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.visiblePassword,
                            maxLength: _isSpeedStream
                                ? (_streamEngine?.activeWord.length ?? 32)
                                : _easyEngine!.targetPhrase.length,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              counterText: '',
                            ),
                            style: const TextStyle(
                              fontSize: 1,
                              color: Colors.transparent,
                            ),
                            cursorColor: Colors.transparent,
                            showCursor: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                if (isPaused) PracticePausedOverlay(onResume: _togglePause),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
