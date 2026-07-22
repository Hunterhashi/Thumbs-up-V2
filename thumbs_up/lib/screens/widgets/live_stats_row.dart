import 'package:flutter/material.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Live performance HUD shown while typing: elapsed time, WPM, accuracy.
class LiveStatsRow extends StatelessWidget {
  const LiveStatsRow({
    super.key,
    required this.elapsed,
    required this.wpm,
    required this.accuracyPercent,
  });

  final Duration elapsed;
  final double wpm;
  final double accuracyPercent;

  String _formatElapsed(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatChip(label: l10n.statsTime, value: _formatElapsed(elapsed)),
        _StatChip(label: l10n.statsWpm, value: wpm.round().toString()),
        _StatChip(
          label: l10n.statsAccuracy,
          value: '${accuracyPercent.round()}%',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.matteBlack,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppColors.appleGray),
        ),
      ],
    );
  }
}
