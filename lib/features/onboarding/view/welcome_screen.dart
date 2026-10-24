import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/models.dart';
import '../../auth/view/login_modal.dart';
import '../../auth/view/signup_modal.dart';
import '../controller/onboarding_controller.dart';
import '../widgets/role_selection_card.dart';

class WelcomeScreen extends StatelessWidget {
  final AppRouter router;
  final OnboardingController controller;

  const WelcomeScreen({
    super.key,
    required this.router,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingXl,
              vertical: AppDimens.paddingXxl,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimens.maxShellWidth,
              ),
              child: _WelcomeBodyContent(
                controller: controller,
                router: router,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeBodyContent extends StatelessWidget {
  final OnboardingController controller;
  final AppRouter router;

  const _WelcomeBodyContent({required this.controller, required this.router});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _WelcomeBrandBadge(),
        const SizedBox(height: AppDimens.p28),
        const _WelcomeHeroCard(),
        const SizedBox(height: AppDimens.p28),
        Text(
          AppStrings.welcomeTitle,
          style: textTheme.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.p10),
        Text(
          AppStrings.welcomeSubtitle,
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.p32),
        _WelcomeRoleSection(controller: controller),
        const SizedBox(height: AppDimens.p32),
        _WelcomeAuthButtons(router: router),
      ],
    );
  }
}

class _WelcomeBrandBadge extends StatelessWidget {
  const _WelcomeBrandBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p8,
        ),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.pets, color: colors.primary, size: AppDimens.iconMd),
            const SizedBox(width: AppDimens.p8),
            Text(
              AppStrings.appName,
              style: AppTypography.toExtraBold(
                textTheme.titleMedium!,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeroCard extends StatelessWidget {
  const _WelcomeHeroCard();

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Container(
      height: AppDimens.heroImageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
        boxShadow: pawTheme.cardShadow,
        image: const DecorationImage(
          image: AssetImage('assets/images/barley.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[pawTheme.transparent, pawTheme.heroGradientBottom],
          ),
        ),
        padding: const EdgeInsets.all(AppDimens.paddingLg),
        alignment: Alignment.bottomLeft,
        child: Text(
          AppStrings.welcomeHeroBadge,
          style: AppTypography.toBold(
            textTheme.titleMedium!,
            color: pawTheme.pureWhite,
          ),
        ),
      ),
    );
  }
}

class _WelcomeRoleSection extends StatelessWidget {
  final OnboardingController controller;

  const _WelcomeRoleSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return ValueListenableBuilder<UserRole>(
      valueListenable: controller,
      builder: (context, currentRole, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            AppStrings.selectDemoRole,
            style: textTheme.titleMedium?.copyWith(color: colors.secondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.p12),
          RoleSelectionCard(
            title: AppStrings.startAsOwnerTitle,
            subtitle: AppStrings.startAsOwnerSubtitle,
            icon: Icons.pets,
            iconBgColor: colors.secondaryContainer,
            iconColor: colors.primary,
            isSelected: currentRole == UserRole.owner,
            onTap: () => controller.selectRoleAndContinue(UserRole.owner),
          ),
          const SizedBox(height: AppDimens.p12),
          RoleSelectionCard(
            title: AppStrings.switchToSitterPanelTitle,
            subtitle: AppStrings.switchToSitterPanelSubtitle,
            icon: Icons.home_work_outlined,
            iconBgColor: pawTheme.tertiaryFixed,
            iconColor: colors.tertiary,
            isSelected: currentRole == UserRole.sitter,
            onTap: () => controller.selectRoleAndContinue(UserRole.sitter),
          ),
        ],
      ),
    );
  }
}

class _WelcomeAuthButtons extends StatelessWidget {
  final AppRouter router;

  const _WelcomeAuthButtons({required this.router});

  ButtonStyle _primaryStyle(ColorScheme colors) => ElevatedButton.styleFrom(
    backgroundColor: colors.primary,
    foregroundColor: colors.onPrimary,
    elevation: AppDimens.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    ),
  );

  ButtonStyle _outlinedStyle(ColorScheme colors) => OutlinedButton.styleFrom(
    side: BorderSide(color: colors.primary, width: AppDimens.borderWidthThick),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: AppDimens.buttonHeight,
          child: ElevatedButton(
            onPressed: () => LoginModal.show(context, router: router),
            style: _primaryStyle(colors),
            child: Text(
              AppStrings.loginButton,
              style: textTheme.titleMedium?.copyWith(color: colors.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.p12),
        SizedBox(
          height: AppDimens.buttonHeight,
          child: OutlinedButton(
            onPressed: () => SignUpModal.show(context, router: router),
            style: _outlinedStyle(colors),
            child: Text(
              AppStrings.createAccountButton,
              style: textTheme.titleMedium?.copyWith(color: colors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
