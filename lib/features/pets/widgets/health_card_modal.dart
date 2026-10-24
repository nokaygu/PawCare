import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../data/models/models.dart';
import '../controller/pets_controller.dart';

class HealthCardModal extends StatelessWidget {
  final PetsController petsController;

  const HealthCardModal({super.key, required this.petsController});

  static Future<void> show(
    BuildContext context, {
    required PetsController petsController,
  }) {
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => HealthCardModal(petsController: petsController),
    );
  }

  BoxDecoration _dialogDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.modalRadius),
      boxShadow: pawTheme.floatingShadow,
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDimens.modalBlurSigma,
        sigmaY: AppDimens.modalBlurSigma,
      ),
      child: Dialog(
        backgroundColor: pawTheme.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingLg,
          vertical: AppDimens.paddingXl,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxShellWidth),
          decoration: _dialogDecoration(colors, pawTheme),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.paddingXl),
            child: ValueListenableBuilder<Dog>(
              valueListenable: petsController,
              builder: (context, dog, _) => _HealthCardModalBody(
                dog: dog,
                petsController: petsController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthCardModalBody extends StatelessWidget {
  final Dog dog;
  final PetsController petsController;

  const _HealthCardModalBody({required this.dog, required this.petsController});

  Widget _addVaccineButton(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightMd,
      child: OutlinedButton.icon(
        onPressed: () =>
            _AddVaccineDialog.show(context, petsController: petsController),
        icon: Icon(Icons.add, color: colors.primary),
        label: Text(AppStrings.addVaccineButton, style: textTheme.bodyLarge),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: colors.primary,
            width: AppDimens.borderWidthThick,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    final upcoming = dog.vaccinations
        .where((v) => v.status == VaccineStatus.upcoming)
        .firstOrNull;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _HealthCardHeader(dog: dog),
        const SizedBox(height: AppDimens.p20),
        _UpcomingVaccineBanner(upcomingVaccine: upcoming),
        const SizedBox(height: AppDimens.p20),
        Text(
          AppStrings.vaccineAndTreatmentRecordsTitle,
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimens.p12),
        _VaccinationsList(
          vaccinations: dog.vaccinations,
          onToggleStatus: petsController.toggleVaccinationStatus,
        ),
        const SizedBox(height: AppDimens.p20),
        _addVaccineButton(context),
      ],
    );
  }
}

class _HealthCardHeader extends StatelessWidget {
  final Dog dog;

  const _HealthCardHeader({required this.dog});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            CircleAvatar(
              radius: AppDimens.avatarRadiusMd,
              backgroundImage: PawImageProvider.resolve(dog.photoPath),
            ),
            const SizedBox(width: AppDimens.p12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.healthCardModalTitle(dog.name),
                  style: textTheme.titleMedium,
                ),
                Text(
                  AppStrings.breedAndAge(dog.breed, dog.ageYears),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.close, color: colors.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: pawTheme.surfaceContainerLow,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}

class _UpcomingVaccineBanner extends StatelessWidget {
  final Vaccination? upcomingVaccine;

  const _UpcomingVaccineBanner({required this.upcomingVaccine});

  Widget _buildBellIcon(ColorScheme colors, PawThemeExtension pawTheme) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.p10),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.notifications_active,
        color: pawTheme.pureWhite,
        size: AppDimens.iconMd,
      ),
    );
  }

  String get _title => upcomingVaccine != null
      ? AppStrings.upcomingVaccineBannerTitle(upcomingVaccine!.title)
      : AppStrings.allVaccinesUpToDateTitle;

  String get _subtitle => upcomingVaccine != null
      ? AppStrings.upcomingVaccineBannerSubtitle(
          upcomingVaccine!.dueDate,
          upcomingVaccine!.vetName,
        )
      : AppStrings.noPlannedVaccineSubtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p16),
      decoration: BoxDecoration(
        color: pawTheme.tertiaryFixed,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(color: pawTheme.accentWarm),
      ),
      child: Row(
        children: <Widget>[
          _buildBellIcon(colors, pawTheme),
          const SizedBox(width: AppDimens.p14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _title,
                  style: AppTypography.toBold(
                    textTheme.bodyLarge!,
                    color: colors.tertiary,
                  ),
                ),
                const SizedBox(height: AppDimens.p2),
                Text(
                  _subtitle,
                  style: textTheme.bodySmall?.copyWith(color: colors.tertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccinationsList extends StatelessWidget {
  final List<Vaccination> vaccinations;
  final ValueChanged<String> onToggleStatus;

  const _VaccinationsList({
    required this.vaccinations,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vaccinations.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p10),
      itemBuilder: (context, index) {
        final vac = vaccinations[index];
        return _HealthCardVaccineRow(
          vaccination: vac,
          onTap: () => onToggleStatus(vac.id),
        );
      },
    );
  }
}

class _HealthCardVaccineRow extends StatelessWidget {
  final Vaccination vaccination;
  final VoidCallback onTap;

  const _HealthCardVaccineRow({required this.vaccination, required this.onTap});

  BoxDecoration _rowDecoration(ColorScheme colors, PawThemeExtension pawTheme) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLow,
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.p14),
        decoration: _rowDecoration(colors, pawTheme),
        child: Row(
          children: <Widget>[
            Icon(
              isDone ? Icons.check_circle : Icons.schedule,
              color: isDone ? pawTheme.success : colors.primary,
              size: AppDimens.iconLg,
            ),
            const SizedBox(width: AppDimens.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(vaccination.title, style: textTheme.bodyLarge),
                  Text(
                    AppStrings.vaccineDateAndVet(
                      vaccination.dueDate,
                      vaccination.vetName,
                    ),
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _HealthVaccineStatusBadge(isDone: isDone),
          ],
        ),
      ),
    );
  }
}

class _HealthVaccineStatusBadge extends StatelessWidget {
  final bool isDone;

  const _HealthVaccineStatusBadge({required this.isDone});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p8,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: isDone ? pawTheme.successContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        isDone ? AppStrings.statusCompleted : AppStrings.statusPending,
        style: textTheme.labelSmall?.copyWith(
          color: isDone ? pawTheme.success : colors.primary,
        ),
      ),
    );
  }
}

class _AddVaccineDialog extends StatefulWidget {
  final PetsController petsController;

  const _AddVaccineDialog({required this.petsController});

  static Future<void> show(
    BuildContext context, {
    required PetsController petsController,
  }) {
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => _AddVaccineDialog(petsController: petsController),
    );
  }

  @override
  State<_AddVaccineDialog> createState() => _AddVaccineDialogState();
}

class _AddVaccineDialogState extends State<_AddVaccineDialog> {
  final TextEditingController _titleController = TextEditingController(
    text: AppStrings.defaultVaccineTitle,
  );
  final TextEditingController _dateController = TextEditingController(
    text: AppStrings.defaultVaccineDate,
  );
  final TextEditingController _vetController = TextEditingController(
    text: AppStrings.defaultVaccineVet,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _vetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await widget.petsController.addVaccination(
      title: _titleController.text,
      dueDate: _dateController.text,
      vetName: _vetController.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return AlertDialog(
      backgroundColor: pawTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
      ),
      title: Text(AppStrings.addVaccineButton, style: textTheme.titleLarge),
      content: _AddVaccineFormFields(
        titleController: _titleController,
        dateController: _dateController,
        vetController: _vetController,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel, style: textTheme.bodyLarge),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          child: const Text(AppStrings.save),
        ),
      ],
    );
  }
}

class _AddVaccineFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController dateController;
  final TextEditingController vetController;

  const _AddVaccineFormFields({
    required this.titleController,
    required this.dateController,
    required this.vetController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldVaccineTitle,
          ),
        ),
        const SizedBox(height: AppDimens.p12),
        TextField(
          controller: dateController,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldPlannedDate,
          ),
        ),
        const SizedBox(height: AppDimens.p12),
        TextField(
          controller: vetController,
          decoration: const InputDecoration(labelText: AppStrings.fieldVetName),
        ),
      ],
    );
  }
}
