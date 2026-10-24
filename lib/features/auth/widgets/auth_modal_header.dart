import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_theme.dart';

class AuthModalHeader extends StatelessWidget {
  final String badgeLabel;
  final String title;
  final String subtitle;

  const AuthModalHeader({
    super.key,
    required this.badgeLabel,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _AuthBadgeChip(badgeLabel: badgeLabel),
            IconButton(
              icon: Icon(Icons.close, color: colors.onSurfaceVariant),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: pawTheme.surfaceContainerLow,
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p18),
        Text(title, style: textTheme.headlineMedium),
        const SizedBox(height: AppDimens.p6),
        Text(subtitle, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _AuthBadgeChip extends StatelessWidget {
  final String badgeLabel;

  const _AuthBadgeChip({required this.badgeLabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p10,
        vertical: AppDimens.p6,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.pets, size: AppDimens.iconXs, color: colors.primary),
          const SizedBox(width: AppDimens.p6),
          Text(
            badgeLabel,
            style: textTheme.labelSmall?.copyWith(color: colors.primary),
          ),
        ],
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;

  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.p16),
      padding: const EdgeInsets.all(AppDimens.p12),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: colors.onErrorContainer,
            size: AppDimens.iconSm,
          ),
          const SizedBox(width: AppDimens.p8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
