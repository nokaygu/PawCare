import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/pets_controller.dart';
import 'dog_form_modals.dart';

class EmptyPetsCard extends StatelessWidget {
  final PetsController controller;

  const EmptyPetsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.p16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.noPetsTitle,
              style: context.pawTextTheme.titleMedium,
            ),
            const SizedBox(height: AppDimens.p8),
            const Text(AppStrings.noPetsBody),
            const SizedBox(height: AppDimens.p12),
            OutlinedButton.icon(
              onPressed: () =>
                  AddDogModal.show(context, petsController: controller),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addFirstPet),
            ),
          ],
        ),
      ),
    );
  }
}
