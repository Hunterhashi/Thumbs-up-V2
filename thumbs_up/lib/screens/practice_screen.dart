import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thumbs_up/data/easy_phrases_en.dart';
import 'package:thumbs_up/lesson/phrase_deck.dart';
import 'package:thumbs_up/models/difficulty.dart';
import 'package:thumbs_up/navigation/app_router.dart';
import 'package:thumbs_up/screens/widgets/live_stats_row.dart';
import 'package:thumbs_up/screens/widgets/phrase_stream_view.dart';
import 'package:thumbs_up/screens/widgets/practice_paused_overlay.dart';
import 'package:thumbs_up/screens/widgets/practice_top_bar.dart';
import 'package:thumbs_up/typing/typing_engine.dart';

/// The typing test itself: shows the target phrase, captures input via a
/// hidden text field, and shows a live WPM/accuracy HUD.
///
/// Only [Difficulty.easy] is playable today; the scrolling "Speed Stream"
/// for Medium/Pro is implemented in a later milestone.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({
    super.key,
    required this.difficulty,
    this.initialPhrase,
  });

  final Difficulty difficulty;

  /// When set, the run starts with this exact phrase instead of drawing a
  /// new one from the deck (used by Results' "Repeat" action).
  final String? initialPhrase;

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late final PhraseDeck _deck;
  late TypingEngine _engine;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _tickTimer;
  bool _navigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _deck = PhraseDeck(easyPhrasesEn);
    _engine = TypingEngine(targetPhrase: widget.initialPhrase ?? _deck.next());
    _controller.addListener(_onControllerChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Keeps the visible timer/WPM ticking even between keystrokes. Skips
    // rebuilding while paused, since elapsed/WPM are frozen anyway.
    _tickTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted &&
          _engine.isStarted &&
          !_engine.completed &&
          !_engine.isPaused) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focusNode.dispose();
    _tickTimer?.cancel();
    super.dispose();
  }

  void _onControllerChanged() {
    _engine.onTextChanged(_controller.text);
    if (_engine.completed && !_navigatedToResult) {
      _navigatedToResult = true;
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (!mounted) return;
        AppRouter.toResult(context, _engine.buildResult(widget.difficulty));
      });
    }
    setState(() {});
  }

  void _restart() {
    setState(() {
      _controller.clear();
      _engine = TypingEngine(targetPhrase: _deck.next());
      _navigatedToResult = false;
    });
    _focusNode.requestFocus();
  }

  void _togglePause() {
    if (_engine.isPaused) {
      _engine.resume();
      setState(() {});
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() {
        _engine.pause();
      });
    }
  }

  Future<bool> _confirmExitIfNeeded() async {
    final inProgress = _engine.isStarted && !_engine.completed;
    if (!inProgress) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave practice?'),
        content: const Text('Your progress on this run will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep typing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
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
    final isPaused = _engine.isPaused;
    final canTogglePause = _engine.isStarted && !_engine.completed;

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
                        title: widget.difficulty.label,
                        onBack: () => _onBack(context),
                        onRestart: _restart,
                        isPaused: isPaused,
                        onPauseResume: canTogglePause ? _togglePause : null,
                      ),
                      const SizedBox(height: 12),
                      LiveStatsRow(
                        elapsed: _engine.elapsed,
                        wpm: _engine.liveWpm,
                        accuracyPercent: _engine.liveAccuracy,
                      ),
                      Expanded(
                        child: Center(
                          child: PhraseStreamView(
                            phrase: _engine.targetPhrase,
                            statuses: _engine.buildCharStatuses(),
                          ),
                        ),
                      ),
                      // Hidden input: captures raw keystrokes without ever
                      // showing a visible cursor/selection to the user, so the
                      // Phrase Stream above is the only thing they look at.
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
                            maxLength: _engine.targetPhrase.length,
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
