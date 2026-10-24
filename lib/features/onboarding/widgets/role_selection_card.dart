import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_theme.dart';

class RoleSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  BoxDecoration _cardDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      boxShadow: pawTheme.cardShadow,
      border: Border.all(
        color: isSelected
            ? colors.primary
            : colors.outlineVariant.withValues(alpha: AppDimens.alphaLight),
        width: AppDimens.borderWidthThick,
      ),
    );
  }

  Widget _buildIconCircle() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.p12),
      decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: AppDimens.iconXl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.p18),
        decoration: _cardDecoration(colors, pawTheme),
        child: Row(
          children: <Widget>[
            _buildIconCircle(),
            const SizedBox(width: AppDimens.p16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: textTheme.titleMedium),
                  const SizedBox(height: AppDimens.p2),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: AppDimens.iconXs,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
