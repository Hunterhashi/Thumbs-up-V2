import 'package:flutter/material.dart';
import 'package:thumbs_up/screens/widgets/phrase_stream_view.dart';
import 'package:thumbs_up/typing/char_status.dart';

/// [PhraseStreamView] with a short vertical transition when [phrase] changes:
/// outgoing slides up/fades out, incoming slides up from below/fades in.
///
/// Status-only updates (typing within the same phrase) do not re-animate,
/// because the switcher key is the phrase string.
class AnimatedPhraseStreamView extends StatelessWidget {
  const AnimatedPhraseStreamView({
    super.key,
    required this.phrase,
    required this.statuses,
  });

  final String phrase;
  final List<CharStatus> statuses;

  static const Duration _duration = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (child, animation) {
        return DualTransitionBuilder(
          animation: animation,
          forwardBuilder: (context, animation, child) {
            return ClipRect(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.35),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
            );
          },
          reverseBuilder: (context, animation, child) {
            return ClipRect(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, -0.35),
                ).animate(animation),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1, end: 0).animate(animation),
                  child: child,
                ),
              ),
            );
          },
          child: child,
        );
      },
      child: PhraseStreamView(
        key: ValueKey<String>(phrase),
        phrase: phrase,
        statuses: statuses,
      ),
    );
  }
}
