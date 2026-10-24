import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/modals/call_modal.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../data/models/models.dart';
import '../controller/pets_controller.dart';
import 'health_card_modal.dart';

class DogSelectorChipsRow extends StatelessWidget {
  final List<Dog> dogs;
  final String selectedDogId;
  final ValueChanged<String> onSelectDog;

  const DogSelectorChipsRow({
    super.key,
    required this.dogs,
    required this.selectedDogId,
    required this.onSelectDog,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dogs.map((item) {
          final isSelected = item.id == selectedDogId;
          return Padding(
            padding: const EdgeInsets.only(right: AppDimens.p8),
            child: ChoiceChip(
              selected: isSelected,
              label: Text(AppStrings.dogChipLabel(item.name, item.breed)),
              labelStyle: isSelected
                  ? AppTypography.toBold(
                      textTheme.bodyLarge!,
                      color: colors.onPrimary,
                    )
                  : textTheme.bodyMedium,
              selectedColor: colors.primary,
              backgroundColor: pawTheme.surfaceContainerLowest,
              checkmarkColor: colors.onPrimary,
              onSelected: (_) => onSelectDog(item.id),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DogPhotoAvatarSection extends StatelessWidget {
  final Dog dog;
  final VoidCallback onPickPhoto;

  const DogPhotoAvatarSection({
    super.key,
    required this.dog,
    required this.onPickPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;

    return Column(
      children: <Widget>[
        Center(
          child: GestureDetector(
            onTap: onPickPhoto,
            child: _AvatarCameraStack(photoPath: dog.photoPath),
          ),
        ),
        const SizedBox(height: AppDimens.p16),
        Center(
          child: Column(
            children: <Widget>[
              Text(dog.name, style: textTheme.displayMedium),
              const SizedBox(height: AppDimens.p2),
              Text(
                AppStrings.microchipSubtitle(dog.breed, dog.microchip),
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarCameraStack extends StatelessWidget {
  final String photoPath;

  const _AvatarCameraStack({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Stack(
      children: <Widget>[
        Container(
          width: AppDimens.dogProfileAvatar,
          height: AppDimens.dogProfileAvatar,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: pawTheme.cardShadow,
            border: Border.all(
              color: pawTheme.pureWhite,
              width: AppDimens.borderWidthAvatar,
            ),
            image: DecorationImage(
              image: PawImageProvider.resolve(photoPath),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: AppDimens.p4,
          right: AppDimens.p4,
          child: Container(
            padding: const EdgeInsets.all(AppDimens.p8),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt,
              color: colors.onPrimary,
              size: AppDimens.iconSm,
            ),
          ),
        ),
      ],
    );
  }
}

class DogStatsRow extends StatelessWidget {
  final Dog dog;

  const DogStatsRow({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _DogStatCard(
          label: AppStrings.statAgeLabel,
          value: AppStrings.ageYearsBadge(dog.ageYears),
        ),
        const SizedBox(width: AppDimens.p10),
        _DogStatCard(
          label: AppStrings.statWeightLabel,
          value: AppStrings.weightKgValue(dog.weightKg),
        ),
        const SizedBox(width: AppDimens.p10),
        _DogStatCard(label: AppStrings.statGenderLabel, value: dog.gender),
      ],
    );
  }
}

class _DogStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _DogStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.p14,
          horizontal: AppDimens.p10,
        ),
        decoration: BoxDecoration(
          color: pawTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: colors.outlineVariant.withValues(
              alpha: AppDimens.alphaSubtle,
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(label, style: textTheme.bodySmall),
            const SizedBox(height: AppDimens.p4),
            Text(value, style: AppTypography.toBold(textTheme.titleMedium!)),
          ],
        ),
      ),
    );
  }
}

class DogProfileActionButtons extends StatelessWidget {
  final VoidCallback onEditProfile;
  final VoidCallback onAddDog;

  const DogProfileActionButtons({
    super.key,
    required this.onEditProfile,
    required this.onAddDog,
  });

  ButtonStyle _outlinedStyle(ColorScheme colors) => OutlinedButton.styleFrom(
    side: BorderSide(color: colors.primary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
    ),
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
  );

  ButtonStyle _primaryStyle(ColorScheme colors) => ElevatedButton.styleFrom(
    backgroundColor: colors.primary,
    foregroundColor: colors.onPrimary,
    elevation: AppDimens.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
    ),
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEditProfile,
            icon: Icon(
              Icons.edit_outlined,
              size: AppDimens.iconSm,
              color: colors.primary,
            ),
            label: Text(AppStrings.editProfileChip, style: textTheme.bodyLarge),
            style: _outlinedStyle(colors),
          ),
        ),
        const SizedBox(width: AppDimens.p12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAddDog,
            icon: const Icon(Icons.add, size: AppDimens.iconSm),
            label: const Text(AppStrings.addNewDogButton),
            style: _primaryStyle(colors),
          ),
        ),
      ],
    );
  }
}

class CriticalHealthWarningCard extends StatelessWidget {
  final String allergyNote;

  const CriticalHealthWarningCard({super.key, required this.allergyNote});

  BoxDecoration _cardDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.warningBg,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      border: Border.all(
        color: colors.error.withValues(alpha: AppDimens.alphaSubtle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p16),
      decoration: _cardDecoration(colors, pawTheme),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _WarningIconBadge(errorColor: colors.error),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.criticalHealthWarningTitle,
                  style: AppTypography.toBold(
                    textTheme.titleMedium!,
                    color: colors.error,
                  ),
                ),
                const SizedBox(height: AppDimens.p4),
                Text(
                  allergyNote,
                  style: textTheme.bodyMedium?.copyWith(
                    color: pawTheme.warningText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningIconBadge extends StatelessWidget {
  final Color errorColor;

  const _WarningIconBadge({required this.errorColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.p8),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: AppDimens.alphaVeryLight),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.warning_amber_rounded,
        color: errorColor,
        size: AppDimens.iconMd,
      ),
    );
  }
}

class VaccineScheduleSection extends StatelessWidget {
  final Dog dog;
  final PetsController petsController;

  const VaccineScheduleSection({
    super.key,
    required this.dog,
    required this.petsController,
  });

  Widget _buildHeaderRow(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          AppStrings.vaccineScheduleSectionTitle,
          style: textTheme.titleLarge,
        ),
        TextButton.icon(
          onPressed: () =>
              HealthCardModal.show(context, petsController: petsController),
          icon: Icon(
            Icons.medical_information_outlined,
            size: AppDimens.iconXs,
            color: colors.primary,
          ),
          label: Text(
            AppStrings.viewSummaryButton,
            style: textTheme.labelSmall?.copyWith(color: colors.primary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeaderRow(context),
        const SizedBox(height: AppDimens.p10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dog.vaccinations.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p10),
          itemBuilder: (context, index) {
            final vac = dog.vaccinations[index];
            return _VaccineItemRow(
              vaccination: vac,
              onToggleStatus: () =>
                  petsController.toggleVaccinationStatus(vac.id),
            );
          },
        ),
      ],
    );
  }
}

class _VaccineItemRow extends StatelessWidget {
  final Vaccination vaccination;
  final VoidCallback onToggleStatus;

  const _VaccineItemRow({
    required this.vaccination,
    required this.onToggleStatus,
  });

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
    final isDone = vaccination.status == VaccineStatus.completed;
    return InkWell(
      onTap: onToggleStatus,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.p14),
        decoration: _rowDecoration(colors, pawTheme),
        child: Row(
          children: <Widget>[
            Icon(
              isDone ? Icons.check_circle : Icons.event,
              color: isDone ? pawTheme.success : colors.primary,
              size: AppDimens.iconXl,
            ),
            const SizedBox(width: AppDimens.p14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(vaccination.title, style: textTheme.titleMedium),
                  const SizedBox(height: AppDimens.p2),
                  Text(
                    '${vaccination.dueDate} • ${vaccination.vetName}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _VaccineStatusPill(isDone: isDone),
          ],
        ),
      ),
    );
  }
}

class _VaccineStatusPill extends StatelessWidget {
  final bool isDone;

  const _VaccineStatusPill({required this.isDone});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p10,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: isDone ? pawTheme.successContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Text(
        isDone ? AppStrings.statusCompleted : AppStrings.statusUpcoming,
        style: textTheme.labelSmall?.copyWith(
          color: isDone ? pawTheme.success : colors.primary,
        ),
      ),
    );
  }
}

class NutritionAndBehaviorSection extends StatelessWidget {
  final String behaviorNote;

  const NutritionAndBehaviorSection({super.key, required this.behaviorNote});

  BoxDecoration _boxDecoration(ColorScheme colors, PawThemeExtension pawTheme) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.nutritionAndBehaviorTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p10),
        Container(
          padding: const EdgeInsets.all(AppDimens.p16),
          decoration: _boxDecoration(colors, pawTheme),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const _NutritionBlockItem(
                icon: Icons.restaurant,
                title: AppStrings.dailyNutritionPlanTitle,
                body: AppStrings.dailyNutritionPlanBody,
              ),
              Divider(
                height: AppDimens.dividerSpace,
                color: colors.outlineVariant,
              ),
              _NutritionBlockItem(
                icon: Icons.favorite_border,
                title: AppStrings.socialBehaviorTitle,
                body: behaviorNote,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionBlockItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _NutritionBlockItem({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: AppDimens.iconSm, color: colors.primary),
            const SizedBox(width: AppDimens.p8),
            Text(title, style: textTheme.bodyLarge),
          ],
        ),
        const SizedBox(height: AppDimens.p6),
        Text(body, style: textTheme.bodyMedium),
      ],
    );
  }
}

class VetClinicCardSection extends StatelessWidget {
  final Dog dog;

  const VetClinicCardSection({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.responsibleVetClinicTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p10),
        Container(
          padding: const EdgeInsets.all(AppDimens.p18),
          decoration: BoxDecoration(
            color: pawTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            boxShadow: pawTheme.cardShadow,
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: AppDimens.alphaSubtle,
              ),
            ),
          ),
          child: _VetClinicInnerRow(dog: dog),
        ),
      ],
    );
  }
}

class _VetClinicInnerRow extends StatelessWidget {
  final Dog dog;

  const _VetClinicInnerRow({required this.dog});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppDimens.p12),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_hospital,
            color: colors.primary,
            size: AppDimens.iconXl,
          ),
        ),
        const SizedBox(width: AppDimens.p14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(dog.clinicName, style: textTheme.titleMedium),
              const SizedBox(height: AppDimens.p2),
              Text(AppStrings.chiefVetSubtitle, style: textTheme.bodySmall),
              Text(
                dog.clinicPhone,
                style: AppTypography.toSemiBold(textTheme.bodySmall!),
              ),
            ],
          ),
        ),
        _CallClinicButton(dog: dog),
      ],
    );
  }
}

class _CallClinicButton extends StatelessWidget {
  final Dog dog;

  const _CallClinicButton({required this.dog});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ElevatedButton.icon(
      onPressed: () => CallModal.show(
        context,
        contactName: AppStrings.vetCallContactName(dog.clinicName),
        roleSubtitle: AppStrings.vetEmergencySubtitle,
        phoneNumber: dog.clinicPhone,
      ),
      icon: const Icon(Icons.phone, size: AppDimens.iconXs),
      label: const Text(AppStrings.callNowButton),
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: AppDimens.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p14,
          vertical: AppDimens.p10,
        ),
      ),
    );
  }
}
