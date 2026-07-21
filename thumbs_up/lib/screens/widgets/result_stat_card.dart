import 'package:flutter/material.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// A single stat tile on the Results screen (e.g. "WPM: 42").
class ResultStatCard extends StatelessWidget {
  const ResultStatCard({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.brandYellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandYellow.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.matteBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.appleGray,
                ),
          ),
        ],
      ),
    );
  }
}
