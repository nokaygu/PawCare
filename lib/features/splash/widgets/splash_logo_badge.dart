import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';

class SplashLogoBadge extends StatelessWidget {
  final Animation<double> scaleAnimation;

  const SplashLogoBadge({super.key, required this.scaleAnimation});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return ScaleTransition(
      scale: scaleAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const _SplashLogoBox(),
          const SizedBox(height: AppDimens.p20),
          Text(
            AppStrings.appName,
            style: AppTypography.toExtraBold(
              textTheme.displayMedium!,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppDimens.p8),
          Text(AppStrings.splashTagline, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SplashLogoBox extends StatelessWidget {
  const _SplashLogoBox();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Container(
      width: AppDimens.splashLogoBox,
      height: AppDimens.splashLogoBox,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        boxShadow: pawTheme.floatingShadow,
      ),
      child: Icon(
        Icons.pets,
        size: AppDimens.iconSplash,
        color: colors.primary,
      ),
    );
  }
}
