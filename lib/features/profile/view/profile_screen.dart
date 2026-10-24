import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../data/models/models.dart';
import '../../pets/controller/pets_controller.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_modals.dart';
import '../widgets/profile_sections.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileController controller;
  final PetsController petsController;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const ProfileScreen({
    super.key,
    required this.controller,
    required this.petsController,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;

    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingLg,
            vertical: AppDimens.paddingLg,
          ),
          child: _ProfileScreenContent(
            controller: controller,
            petsController: petsController,
            unreadNotifications: unreadNotifications,
            onNotificationsTap: onNotificationsTap,
          ),
        ),
      ),
    );
  }
}

class _ProfileScreenContent extends StatelessWidget {
  final ProfileController controller;
  final PetsController petsController;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _ProfileScreenContent({
    required this.controller,
    required this.petsController,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ProfileHeaderBar(
          unreadNotifications: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
        const SizedBox(height: AppDimens.p20),
        _ReactiveProfileSummary(
          controller: controller,
          petsController: petsController,
        ),
        const SizedBox(height: AppDimens.p24),
        Text(
          AppStrings.settingsAndPreferencesTitle,
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimens.p12),
        ProfileThemeSelectorCard(themeController: controller.themeController),
        const SizedBox(height: AppDimens.p8),
        ProfileSettingsList(
          onNotificationsTap: onNotificationsTap,
          onToggleRole: controller.toggleRole,
          onPaymentTap: () => ProfileInfoModal.showPaymentMethods(context),
          onPrivacyTap: () => ProfileInfoModal.showPrivacySecurity(context),
          onHelpTap: () => ProfileInfoModal.showHelpSupport(context),
        ),
        const SizedBox(height: AppDimens.p24),
        _LogoutButton(onTap: controller.openWelcomeScreen),
      ],
    );
  }
}

class _ReactiveProfileSummary extends StatelessWidget {
  final ProfileController controller;
  final PetsController petsController;

  const _ReactiveProfileSummary({
    required this.controller,
    required this.petsController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller,
      builder: (context, _, _) {
        return ValueListenableBuilder<Dog>(
          valueListenable: petsController,
          builder: (context, dog, _) => ProfileUserSummaryCard(
            userName: controller.activeDisplayName,
            userEmail: controller.activeDisplayEmail,
            avatarPath: controller.activeAvatarPath,
            dogs: petsController.allDogs,
            role: controller.role,
            onEditTap: () =>
                EditUserProfileModal.show(context, controller: controller),
          ),
        );
      },
    );
  }
}

class _ProfileHeaderBar extends StatelessWidget {
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _ProfileHeaderBar({
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            AppStrings.accountAndProfileTitle,
            style: textTheme.headlineMedium,
          ),
        ),
        PawHeaderActions(
          unreadCount: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppDimens.p14),
        ),
        child: Text(
          AppStrings.logoutOrSwitchRoleButton,
          style: textTheme.bodyLarge?.copyWith(color: colors.error),
        ),
      ),
    );
  }
}
