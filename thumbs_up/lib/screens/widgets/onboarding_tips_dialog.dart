import 'package:flutter/material.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Shows the one-time onboarding tips dialog. Callers are responsible for
/// only calling this once (see `OnboardingStore`).
Future<void> showOnboardingTipsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Welcome to Thumbs Up'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Tip(
            icon: Icons.keyboard_rounded,
            text:
                'Pick a difficulty, then type the highlighted phrase as '
                'fast and accurately as you can.',
          ),
          SizedBox(height: 14),
          _Tip(
            icon: Icons.palette_rounded,
            text:
                'Correct keys turn green, mistakes turn red — backspace '
                "doesn't erase the mistake count.",
          ),
          SizedBox(height: 14),
          _Tip(
            icon: Icons.pause_circle_rounded,
            text:
                'Tap the pause button anytime; your personal best is '
                'saved automatically.',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
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
