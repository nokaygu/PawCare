import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../data/models/models.dart';
import '../controller/pets_controller.dart';
import '../widgets/dog_form_modals.dart';
import '../widgets/dog_profile_sections.dart';

class DogProfileScreen extends StatelessWidget {
  final PetsController petsController;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const DogProfileScreen({
    super.key,
    required this.petsController,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  Future<void> _handlePhotoPick(BuildContext context) async {
    final updated = await petsController.pickAndUpdatePhoto();
    if (!context.mounted || !updated) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppStrings.photoUpdatedSnack)));
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;

    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: ValueListenableBuilder<Dog>(
          valueListenable: petsController,
          builder: (context, dog, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLg,
                vertical: AppDimens.paddingLg,
              ),
              child: _DogProfileContent(
                dog: dog,
                petsController: petsController,
                unreadNotifications: unreadNotifications,
                onNotificationsTap: onNotificationsTap,
                onPickPhoto: () => _handlePhotoPick(context),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DogProfileContent extends StatelessWidget {
  final Dog dog;
  final PetsController petsController;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;
  final VoidCallback onPickPhoto;

  const _DogProfileContent({
    required this.dog,
    required this.petsController,
    required this.unreadNotifications,
    required this.onNotificationsTap,
    required this.onPickPhoto,
  });

  Widget _buildActionRow(BuildContext context) {
    return DogProfileActionButtons(
      onEditProfile: () => EditDogProfileModal.show(
        context,
        dog: dog,
        petsController: petsController,
      ),
      onAddDog: () => AddDogModal.show(context, petsController: petsController),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allDogs = petsController.allDogs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DogProfileHeader(
          dog: dog,
          unreadNotifications: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
        if (allDogs.length > 1) ...<Widget>[
          const SizedBox(height: AppDimens.p14),
          DogSelectorChipsRow(
            dogs: allDogs,
            selectedDogId: dog.id,
            onSelectDog: petsController.selectDog,
          ),
        ],
        const SizedBox(height: AppDimens.p20),
        DogPhotoAvatarSection(dog: dog, onPickPhoto: onPickPhoto),
        const SizedBox(height: AppDimens.p20),
        DogStatsRow(dog: dog),
        const SizedBox(height: AppDimens.p16),
        _buildActionRow(context),
        const SizedBox(height: AppDimens.p24),
        CriticalHealthWarningCard(allergyNote: dog.allergyNote),
        const SizedBox(height: AppDimens.p24),
        VaccineScheduleSection(dog: dog, petsController: petsController),
        const SizedBox(height: AppDimens.p24),
        NutritionAndBehaviorSection(behaviorNote: dog.behaviorNote),
        const SizedBox(height: AppDimens.p24),
        VetClinicCardSection(dog: dog),
        const SizedBox(height: AppDimens.p24),
      ],
    );
  }
}

class _DogProfileHeader extends StatelessWidget {
  final Dog dog;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _DogProfileHeader({
    required this.dog,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            AppStrings.dogProfileHeaderTitle,
            style: textTheme.headlineMedium,
          ),
        ),
        IconButton(
          icon: Icon(Icons.qr_code, color: colors.primary),
          onPressed: () => MicrochipIdentityModal.show(context, dog: dog),
          style: IconButton.styleFrom(
            backgroundColor: pawTheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusButton),
              side: BorderSide(
                color: colors.outlineVariant.withValues(
                  alpha: AppDimens.alphaLight,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.p8),
        PawHeaderActions(
          unreadCount: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}
