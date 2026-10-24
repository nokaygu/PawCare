import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../pets/controller/pets_controller.dart';
import '../../pets/widgets/dog_profile_sections.dart';
import '../controller/home_controller.dart';
import '../widgets/owner_home_sections.dart';

class OwnerHomeScreen extends StatelessWidget {
  final HomeController homeController;
  final PetsController petsController;
  final ValueChanged<SitterListing> onSitterSelected;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const OwnerHomeScreen({
    super.key,
    required this.homeController,
    required this.petsController,
    required this.onSitterSelected,
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
          child: _OwnerHomeBody(
            homeController: homeController,
            petsController: petsController,
            onSitterSelected: onSitterSelected,
            unreadNotifications: unreadNotifications,
            onNotificationsTap: onNotificationsTap,
          ),
        ),
      ),
    );
  }
}

class _OwnerHomeBody extends StatelessWidget {
  final HomeController homeController;
  final PetsController petsController;
  final ValueChanged<SitterListing> onSitterSelected;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _OwnerHomeBody({
    required this.homeController,
    required this.petsController,
    required this.onSitterSelected,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  Widget _buildHeaderListener() => ValueListenableBuilder<Dog>(
    valueListenable: petsController,
    builder: (_, dog, _) => OwnerHomeTopHeader(
      ownerName: homeController.ownerFirstName,
      dogName: dog.name,
      onSwitchRole: homeController.switchToSitterMode,
      unreadNotifications: unreadNotifications,
      onNotificationsTap: onNotificationsTap,
    ),
  );

  Widget _buildDogListener() => ValueListenableBuilder<Dog>(
    valueListenable: petsController,
    builder: (_, dog, _) {
      final allDogs = petsController.allDogs;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (allDogs.length > 1) ...<Widget>[
            DogSelectorChipsRow(
              dogs: allDogs,
              selectedDogId: dog.id,
              onSelectDog: petsController.selectDog,
            ),
            const SizedBox(height: AppDimens.p12),
          ],
          DogQuickProfileCard(dog: dog, petsController: petsController),
        ],
      );
    },
  );

  Widget _buildSittersListener() => ValueListenableBuilder<List<SitterListing>>(
    valueListenable: homeController,
    builder: (_, sitters, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TodaysReservationLiveCard(
          activeBooking: homeController.activeConfirmedBooking,
          onExplore: homeController.openExploreTab,
        ),
        const SizedBox(height: AppDimens.p24),
        FeaturedSittersSection(
          sitters: sitters,
          onSeeAll: homeController.openExploreTab,
          onSitterTap: onSitterSelected,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeaderListener(),
        const SizedBox(height: AppDimens.p20),
        _buildDogListener(),
        const SizedBox(height: AppDimens.p22),
        UpcomingVaccineAlertCard(petsController: petsController),
        const SizedBox(height: AppDimens.p22),
        _buildSittersListener(),
        const SizedBox(height: AppDimens.p20),
      ],
    );
  }
}
