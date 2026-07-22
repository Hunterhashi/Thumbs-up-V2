import 'package:flutter/material.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Full-bleed overlay shown on top of the Practice screen while the run is
/// paused: blocks the Phrase Stream from view and offers a way to resume.
class PracticePausedOverlay extends StatelessWidget {
  const PracticePausedOverlay({super.key, required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Positioned.fill(
      child: ColoredBox(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.96),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.pause_circle_filled_rounded,
                size: 56,
                color: AppColors.brandYellow,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pausedTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.pausedResumeButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
