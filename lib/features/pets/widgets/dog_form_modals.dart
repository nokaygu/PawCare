import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/models.dart';
import '../controller/pets_controller.dart';
import 'dog_editor_modal.dart';

class EditDogProfileModal extends StatelessWidget {
  final Dog dog;
  final PetsController petsController;
  const EditDogProfileModal({
    super.key,
    required this.dog,
    required this.petsController,
  });
  static Future<void> show(
    BuildContext context, {
    required Dog dog,
    required PetsController petsController,
  }) => showDialog<void>(
    context: context,
    barrierColor: context.pawTheme.modalBarrier,
    builder: (_) =>
        EditDogProfileModal(dog: dog, petsController: petsController),
  );
  @override
  Widget build(BuildContext context) =>
      DogEditorModal(controller: petsController, initialDog: dog);
}

class AddDogModal extends StatelessWidget {
  final PetsController petsController;
  const AddDogModal({super.key, required this.petsController});
  static Future<void> show(
    BuildContext context, {
    required PetsController petsController,
  }) => showDialog<void>(
    context: context,
    barrierColor: context.pawTheme.modalBarrier,
    builder: (_) => AddDogModal(petsController: petsController),
  );
  @override
  Widget build(BuildContext context) =>
      DogEditorModal(controller: petsController);
}

class MicrochipIdentityModal extends StatelessWidget {
  final Dog dog;

  const MicrochipIdentityModal({super.key, required this.dog});

  static Future<void> show(BuildContext context, {required Dog dog}) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) => MicrochipIdentityModal(dog: dog),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return AlertDialog(
      backgroundColor: pawTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
      ),
      title: Text(
        AppStrings.digitalIdentityTitle(dog.name),
        style: textTheme.titleLarge,
      ),
      content: _MicrochipModalBody(dog: dog),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.close),
        ),
      ],
    );
  }
}

class _MicrochipModalBody extends StatelessWidget {
  final Dog dog;

  const _MicrochipModalBody({required this.dog});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.badge_outlined,
          size: AppDimens.splashLogoBox,
          color: colors.primary,
        ),
        const SizedBox(height: AppDimens.p12),
        Text(
          dog.microchip.isEmpty ? AppStrings.notProvided : dog.microchip,
          style: AppTypography.toExtraBold(
            textTheme.titleMedium!,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: AppDimens.p6),
        Text(
          AppStrings.breedAgeWeight(dog.breed, dog.ageYears, dog.weightKg),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimens.p4),
        Text(
          AppStrings.clinicPrefix(dog.clinicName),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}
