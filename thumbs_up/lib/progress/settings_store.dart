import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable snapshot of the user's app-wide preferences.
class AppSettings {
  const AppSettings({
    this.hapticsEnabled = true,
    this.hudEnabled = true,
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  final bool hapticsEnabled;
  final bool hudEnabled;
  final ThemeMode themeMode;

  /// Manually chosen UI language, or null to follow the device locale.
  final Locale? locale;

  AppSettings copyWith({
    bool? hapticsEnabled,
    bool? hudEnabled,
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
  }) {
    return AppSettings(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      hudEnabled: hudEnabled ?? this.hudEnabled,
      themeMode: themeMode ?? this.themeMode,
      locale: clearLocale ? null : (locale ?? this.locale),
    );
  }
}

/// Persists and broadcasts the user's Settings (haptics, live HUD, theme
/// mode), backed by `shared_preferences`.
///
/// Other widgets (e.g. `HapticEngine`, `PracticeScreen`, `ThumbsUpApp`) read
/// the always-current value via [current] or listen to [notifier] — this
/// keeps the app's "no heavy state management" approach while still letting
/// a Settings change (like theme mode) update the UI immediately.
class SettingsStore {
  SettingsStore._();

  static const String _hapticsKey = 'settings_haptics_enabled';
  static const String _hudKey = 'settings_hud_enabled';
  static const String _themeModeKey = 'settings_theme_mode';
  static const String _localeKey = 'settings_locale';

  static final ValueNotifier<AppSettings> notifier = ValueNotifier(
    const AppSettings(),
  );

  static AppSettings get current => notifier.value;

  /// Loads persisted settings into [notifier]. Call once on app startup,
  /// before the first frame that depends on them is built.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    notifier.value = AppSettings(
      hapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
      hudEnabled: prefs.getBool(_hudKey) ?? true,
      themeMode: _themeModeFromString(prefs.getString(_themeModeKey)),
      locale: _localeFromString(prefs.getString(_localeKey)),
    );
  }

  static Future<void> setHapticsEnabled(bool enabled) async {
    notifier.value = notifier.value.copyWith(hapticsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, enabled);
  }

  static Future<void> setHudEnabled(bool enabled) async {
    notifier.value = notifier.value.copyWith(hudEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hudKey, enabled);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    notifier.value = notifier.value.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  /// Sets the manual UI language, or clears it (pass null) to follow the
  /// device locale again.
  static Future<void> setLocale(Locale? locale) async {
    notifier.value = notifier.value.copyWith(
      locale: locale,
      clearLocale: locale == null,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale?.languageCode ?? 'system');
  }

  static ThemeMode _themeModeFromString(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Locale? _localeFromString(String? value) {
    return switch (value) {
      'en' => const Locale('en'),
      'de' => const Locale('de'),
      _ => null,
    };
  }
}
