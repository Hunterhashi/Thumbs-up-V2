import 'package:flutter/material.dart';
import 'package:thumbs_up/progress/settings_store.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// Lets the user toggle haptic feedback, the live stats HUD, and the app's
/// theme mode. Changes are applied immediately and persisted via
/// [SettingsStore].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<AppSettings>(
          valueListenable: SettingsStore.notifier,
          builder: (context, settings, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                _SettingsSection(
                  title: 'Practice',
                  children: [
                    SwitchListTile.adaptive(
                      value: settings.hapticsEnabled,
                      onChanged: SettingsStore.setHapticsEnabled,
                      title: const Text('Haptic feedback'),
                      subtitle: const Text(
                        'Vibrate on correct and incorrect keys',
                      ),
                      activeThumbColor: AppColors.brandYellow,
                    ),
                    const Divider(height: 1),
                    SwitchListTile.adaptive(
                      value: settings.hudEnabled,
                      onChanged: SettingsStore.setHudEnabled,
                      title: const Text('Live stats HUD'),
                      subtitle: const Text(
                        'Show time, WPM and accuracy while typing',
                      ),
                      activeThumbColor: AppColors.brandYellow,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SettingsSection(
                  title: 'Appearance',
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
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('System'),
          icon: Icon(Icons.brightness_auto_rounded),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Light'),
          icon: Icon(Icons.light_mode_rounded),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode_rounded),
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
