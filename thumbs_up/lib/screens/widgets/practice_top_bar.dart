import 'package:flutter/material.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Top bar for the Practice screen: Back/Home on the left, difficulty
/// title centered, Restart on the right.
class PracticeTopBar extends StatelessWidget {
  const PracticeTopBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onRestart,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onRestart;

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
        _TopBarButton(icon: Icons.refresh_rounded, onTap: onRestart),
      ],
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

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
          child: Icon(icon, size: 22, color: AppColors.matteBlack),
        ),
      ),
    );
  }
}
