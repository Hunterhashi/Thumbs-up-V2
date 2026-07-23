import 'package:flutter/material.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/models/phrase_category.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Row of chips letting the user pick which phrase pack (see
/// `PhrasePackResolver`) the next Practice run will draw from.
class PhraseCategorySelector extends StatelessWidget {
  const PhraseCategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PhraseCategory selected;
  final ValueChanged<PhraseCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: PhraseCategory.values.map((category) {
        final isSelected = category == selected;
        return ChoiceChip(
          label: Text(category.label(l10n)),
          selected: isSelected,
          onSelected: (_) => onChanged(category),
          showCheckmark: false,
          backgroundColor: theme.colorScheme.surface,
          selectedColor: AppColors.brandYellow,
          side: BorderSide(
            color: AppColors.appleGray.withValues(alpha: isSelected ? 0 : 0.25),
          ),
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? AppColors.matteBlack : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        );
      }).toList(),
    );
  }
}
