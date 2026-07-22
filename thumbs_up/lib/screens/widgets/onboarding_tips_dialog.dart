import 'package:flutter/material.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Shows the one-time onboarding tips dialog. Callers are responsible for
/// only calling this once (see `OnboardingStore`).
Future<void> showOnboardingTipsDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.onboardingTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tip(icon: Icons.keyboard_rounded, text: l10n.onboardingTip1),
          const SizedBox(height: 14),
          _Tip(icon: Icons.palette_rounded, text: l10n.onboardingTip2),
          const SizedBox(height: 14),
          _Tip(icon: Icons.pause_circle_rounded, text: l10n.onboardingTip3),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.onboardingGotIt),
        ),
      ],
    ),
  );
}

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.brandYellow),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
