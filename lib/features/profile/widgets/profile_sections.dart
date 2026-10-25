import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../data/models/models.dart';

class ProfileUserSummaryCard extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String? avatarPath;
  final List<Dog> dogs;
  final UserRole role;
  final VoidCallback onEditTap;

  const ProfileUserSummaryCard({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.avatarPath,
    required this.dogs,
    required this.role,
    required this.onEditTap,
  });

  String _roleSubtitle() {
    if (role == UserRole.sitter) {
      return AppStrings.sitterProfileRoleSubtitle;
    }
    final dogNames = dogs.map((d) => d.name).join(', ');
    return AppStrings.ownerProfileRoleSubtitle(dogs.length, dogNames);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p18),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: pawTheme.cardShadow,
      ),
      child: Row(
        children: <Widget>[
          _ProfileSummaryAvatar(avatarPath: avatarPath),
          const SizedBox(width: AppDimens.p14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(userName, style: textTheme.titleLarge),
                Text(userEmail, style: textTheme.bodySmall),
                const SizedBox(height: AppDimens.p4),
                Text(_roleSubtitle(), style: textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: colors.primary),
            onPressed: onEditTap,
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryAvatar extends StatelessWidget {
  final String? avatarPath;

  const _ProfileSummaryAvatar({required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (avatarPath != null) {
      return CircleAvatar(
        radius: AppDimens.avatarRadiusProfile,
        backgroundImage: PawImageProvider.avatar(
          context,
          avatarPath!,
          radius: AppDimens.avatarRadiusProfile,
        ),
      );
    }
    return CircleAvatar(
      radius: AppDimens.avatarRadiusProfile,
      backgroundColor: colors.secondaryContainer,
      child: Icon(
        Icons.person,
        size: AppDimens.iconHero,
        color: colors.primary,
      ),
    );
  }
}

class ProfileThemeSelectorCard extends StatelessWidget {
  final ThemeController themeController;

  const ProfileThemeSelectorCard({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) => _ThemeSelectorRow(
        isDark: mode == ThemeMode.dark,
        onChanged: themeController.isBusy
            ? null
            : (isDark) => performUiAction(
                context,
                () => themeController.setDarkMode(isDark),
              ),
      ),
    );
  }
}

class _ThemeSelectorRow extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool>? onChanged;

  const _ThemeSelectorRow({required this.isDark, required this.onChanged});

  BoxDecoration _rowDecoration(ColorScheme colors, PawThemeExtension pawTheme) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    final statusText = isDark
        ? AppStrings.darkThemeActiveSubtitle
        : AppStrings.lightThemeActiveSubtitle;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p14),
      decoration: _rowDecoration(colors, pawTheme),
      child: Row(
        children: <Widget>[
          Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: colors.primary,
            size: AppDimens.iconMd,
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.darkKhakiThemeTitle,
                  style: textTheme.bodyLarge,
                ),
                Text(statusText, style: textTheme.bodySmall),
              ],
            ),
          ),
          Switch(value: isDark, onChanged: onChanged),
        ],
      ),
    );
  }
}

class ProfileSettingsList extends StatelessWidget {
  final VoidCallback onNotificationsTap;
  final VoidCallback onToggleRole;
  final VoidCallback onPaymentTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onHelpTap;

  const ProfileSettingsList({
    super.key,
    required this.onNotificationsTap,
    required this.onToggleRole,
    required this.onPaymentTap,
    required this.onPrivacyTap,
    required this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _ProfileSettingTile(
          icon: Icons.notifications_outlined,
          title: AppStrings.notificationPreferencesTitle,
          onTap: onNotificationsTap,
        ),
        const SizedBox(height: AppDimens.p8),
        _ProfileSettingTile(
          icon: Icons.swap_horiz_outlined,
          title: AppStrings.switchActiveRoleTitle,
          onTap: onToggleRole,
        ),
        const SizedBox(height: AppDimens.p8),
        _ProfileSettingTile(
          icon: Icons.credit_card_outlined,
          title: AppStrings.paymentMethodsTitle,
          onTap: onPaymentTap,
        ),
        const SizedBox(height: AppDimens.p8),
        _ProfileSettingTile(
          icon: Icons.security_outlined,
          title: AppStrings.privacyAndSecurityTitle,
          onTap: onPrivacyTap,
        ),
        const SizedBox(height: AppDimens.p8),
        _ProfileSettingTile(
          icon: Icons.help_outline,
          title: AppStrings.helpAndSupportTitle,
          onTap: onHelpTap,
        ),
      ],
    );
  }
}

class _ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _ProfileSettingTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.p14),
        decoration: BoxDecoration(
          color: pawTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: colors.outlineVariant.withValues(
              alpha: AppDimens.alphaSubtle,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: colors.secondary, size: AppDimens.iconMd),
            const SizedBox(width: AppDimens.p12),
            Expanded(child: Text(title, style: textTheme.bodyLarge)),
            Icon(
              Icons.chevron_right,
              color: colors.onSurfaceVariant,
              size: AppDimens.iconSm,
            ),
          ],
        ),
      ),
    );
  }
}
