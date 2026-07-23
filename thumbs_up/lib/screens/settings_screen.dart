import 'package:flutter/material.dart';
import 'package:thumbs_up/l10n/generated/app_localizations.dart';
import 'package:thumbs_up/progress/settings_store.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Lets the user toggle haptic feedback, the live stats HUD, the app's
/// theme mode, and the UI language. Changes are applied immediately and
/// persisted via [SettingsStore].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<AppSettings>(
          valueListenable: SettingsStore.notifier,
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _SettingsSection(
                  title: l10n.settingsSectionPractice,
                  children: [
                    SwitchListTile.adaptive(
                      value: settings.hapticsEnabled,
                      onChanged: SettingsStore.setHapticsEnabled,
                      title: Text(l10n.settingsHapticsTitle),
                      subtitle: Text(l10n.settingsHapticsSubtitle),
                      activeThumbColor: AppColors.brandYellow,
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      value: settings.hudEnabled,
                      onChanged: SettingsStore.setHudEnabled,
                      title: Text(l10n.settingsHudTitle),
                      subtitle: Text(l10n.settingsHudSubtitle),
                      activeThumbColor: AppColors.brandYellow,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: l10n.settingsSectionAppearance,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: _ThemeModeSelector(
                        value: settings.themeMode,
                        onChanged: SettingsStore.setThemeMode,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: l10n.settingsSectionLanguage,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: _LanguageSelector(
                        value: settings.locale,
                        onChanged: SettingsStore.setLocale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.settingsCredits,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title, style: theme.textTheme.labelLarge),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.appleGray.withValues(alpha: 0.18),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text(l10n.themeModeSystem),
          icon: const Icon(Icons.brightness_auto_rounded),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text(l10n.themeModeLight),
          icon: const Icon(Icons.light_mode_rounded),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text(l10n.themeModeDark),
          icon: const Icon(Icons.dark_mode_rounded),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.brandYellow,
        selectedForegroundColor: AppColors.matteBlack,
      ),
    );
  }
}

/// A `null` value means "follow the device locale".
class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({required this.value, required this.onChanged});

  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<Locale?>(
      segments: [
        ButtonSegment(value: null, label: Text(l10n.languageSystem)),
        ButtonSegment(
          value: const Locale('en'),
          label: Text(l10n.languageEnglish),
        ),
        ButtonSegment(
          value: const Locale('de'),
          label: Text(l10n.languageGerman),
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.brandYellow,
        selectedForegroundColor: AppColors.matteBlack,
      ),
    );
  }
}
