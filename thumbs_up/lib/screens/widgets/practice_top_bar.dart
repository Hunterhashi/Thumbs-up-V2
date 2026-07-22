import 'package:flutter/material.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Top bar for the Practice screen: Back/Home on the left, difficulty
/// title centered, Pause/Resume + Restart on the right.
class PracticeTopBar extends StatelessWidget {
  const PracticeTopBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onRestart,
    this.isPaused = false,
    this.onPauseResume,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onRestart;

  /// Whether the run is currently paused (controls the pause/resume icon).
  final bool isPaused;

  /// Null while there's nothing to pause yet (not started) or the run has
  /// already finished — the button is shown disabled in that case.
  final VoidCallback? onPauseResume;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TopBarButton(icon: Icons.close_rounded, onTap: onBack),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _TopBarButton(
          icon: isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          onTap: onPauseResume,
        ),
        _TopBarButton(icon: Icons.refresh_rounded, onTap: onRestart),
      ],
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({required this.icon, required this.onTap});

  final IconData icon;

  /// Rendered as a disabled (dimmed, non-interactive) button when null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 22,
            color: onTap == null
                ? AppColors.appleGray.withValues(alpha: 0.4)
                : AppColors.matteBlack,
          ),
        ),
      ),
    );
  }
}
