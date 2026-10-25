import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router/app_router.dart';
import 'router/app_shell.dart';

class PawCareApp extends StatefulWidget {
  final bool startWithSplash;
  final bool respectFirstLaunch;

  const PawCareApp({
    super.key,
    this.startWithSplash = false,
    this.respectFirstLaunch = false,
  });

  @override
  State<PawCareApp> createState() => _PawCareAppState();
}

class _PawCareAppState extends State<PawCareApp> {
  late final ThemeController _themeController;
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _themeController = ThemeController();
    _router = AppRouter(
      startWithSplash: widget.startWithSplash,
      respectFirstLaunch: widget.respectFirstLaunch,
    );
  }

  @override
  void dispose() {
    _themeController.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: AppShell(router: _router, themeController: _themeController),
        );
      },
    );
  }
}
