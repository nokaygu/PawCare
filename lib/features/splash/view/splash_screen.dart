import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/splash_logo_badge.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({super.key, required this.onFinished});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 0.94,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingXl),
            child: GestureDetector(
              onTap: widget.onFinished,
              child: SplashLogoBadge(scaleAnimation: _scaleAnimation),
            ),
          ),
        ),
      ),
    );
  }
}
