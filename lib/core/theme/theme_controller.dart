import 'package:flutter/material.dart';

import '../../data/repositories/settings_repository.dart';
import '../utils/lifecycle_notifier.dart';

class ThemeController extends LifecycleNotifier<ThemeMode> {
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
    await runExclusive(() async {
      await _settingsRepository.setIsDarkMode(isDark);
      value = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }
}
