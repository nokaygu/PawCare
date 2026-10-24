import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

class PawBottomNav extends StatelessWidget {
  final UserRole role;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const PawBottomNav({
    super.key,
    required this.role,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<_NavItemData> _ownerItems = <_NavItemData>[
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: AppStrings.navHome,
    ),
    _NavItemData(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: AppStrings.navExplore,
    ),
    _NavItemData(
      icon: Icons.pets_outlined,
      activeIcon: Icons.pets,
      label: AppStrings.navMyDogs,
    ),
    _NavItemData(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month,
      label: AppStrings.navMyRequests,
    ),
    _NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: AppStrings.navProfile,
    ),
  ];

  static const List<_NavItemData> _sitterItems = <_NavItemData>[
    _NavItemData(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: AppStrings.navDashboard,
    ),
    _NavItemData(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: AppStrings.navMyListing,
    ),
    _NavItemData(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: AppStrings.navCalendar,
    ),
    _NavItemData(
      icon: Icons.star_outline,
      activeIcon: Icons.star,
      label: AppStrings.navReviews,
    ),
    _NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: AppStrings.navProfile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final items = role == UserRole.owner ? _ownerItems : _sitterItems;

    return Container(
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(
              alpha: AppDimens.alphaLight,
            ),
            width: AppDimens.borderWidthThin,
          ),
        ),
        boxShadow: pawTheme.navBarShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppDimens.navBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(items.length, (index) {
              return _NavTabButton(
                item: items[index],
                isSelected: index == currentIndex,
                onTap: () => onTabSelected(index),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  final _NavItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    final fgColor = isSelected ? colors.primary : colors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildIconPill(colors, pawTheme, fgColor),
            const SizedBox(height: AppDimens.p2),
            Text(
              item.label,
              style: AppTypography.toMicroTag(
                textTheme.labelSmall!,
                color: fgColor,
                bold: isSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPill(
    ColorScheme colors,
    PawThemeExtension pawTheme,
    Color fgColor,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p14,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: isSelected ? colors.secondaryContainer : pawTheme.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Icon(
        isSelected ? item.activeIcon : item.icon,
        color: fgColor,
        size: AppDimens.iconLg,
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
