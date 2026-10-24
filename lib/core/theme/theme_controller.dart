import 'package:flutter/material.dart';

import '../../data/repositories/settings_repository.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
  final SettingsRepository _settingsRepository;

  ThemeController({SettingsRepository? settingsRepository})
    : _settingsRepository = settingsRepository ?? const SettingsRepository(),
      super(
        (settingsRepository ?? const SettingsRepository()).getIsDarkMode()
            ? ThemeMode.dark
            : ThemeMode.light,
      );

  bool get isDarkMode => value == ThemeMode.dark;

  Future<void> setDarkMode(bool isDark) async {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    await _settingsRepository.setIsDarkMode(isDark);
  }

  Future<void> toggleTheme() async {
    await setDarkMode(!isDarkMode);
  }
}
