import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/widgets/paw_paged_list.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../core/widgets/paw_vaccine_status_badge.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../data/models/models.dart';
import '../../../data/models/health_summary.dart';
import '../controller/pets_controller.dart';
import 'empty_pets_card.dart';
import 'health_summary_labels.dart';

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
            child: ValueListenableBuilder<Dog?>(
              valueListenable: petsController,
              builder: (context, dog, _) => dog == null
                  ? EmptyPetsCard(controller: petsController)
                  : _HealthCardModalBody(
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _HealthCardHeader(dog: dog),
        const SizedBox(height: AppDimens.p20),
        _UpcomingVaccineBanner(summary: petsController.healthSummary),
        const SizedBox(height: AppDimens.p20),
        Text(
          AppStrings.vaccineAndTreatmentRecordsTitle,
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: AppDimens.p12),
        _VaccinationsList(
          vaccinations: dog.vaccinations,
          onToggleStatus: (id) => performUiAction(
            context,
            () => petsController.toggleVaccinationStatus(id),
          ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        _buildIdentity(context),
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

  Widget _buildIdentity(BuildContext context) {
    final textTheme = context.pawTextTheme;

    return Expanded(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: AppDimens.avatarRadiusMd,
            backgroundImage: PawImageProvider.avatar(
              context,
              dog.photoPath,
              radius: AppDimens.avatarRadiusMd,
            ),
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.healthCardModalTitle(dog.name),
                  style: textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppStrings.breedAndAge(dog.breed, dog.ageYears),
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingVaccineBanner extends StatelessWidget {
  final HealthSummary summary;

  const _UpcomingVaccineBanner({required this.summary});

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

  String get _title => summary.title;
  String get _subtitle => summary.subtitle;

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
    return PawPagedList(
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
            PawVaccineStatusBadge(status: vaccination.statusAt(DateTime.now())),
          ],
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
    text: '',
  );
  final TextEditingController _dateController = TextEditingController(text: '');
  DateTime? _selectedDate;
  final TextEditingController _vetController = TextEditingController(text: '');

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _vetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final date = _selectedDate;
    if (date == null) throw ArgumentError(AppStrings.invalidVaccineDate);
    await widget.petsController.addVaccination(
      title: _titleController.text,
      dueAt: date,
      vetName: _vetController.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: AppStrings.fieldPlannedDate,
      cancelText: AppStrings.cancel,
      confirmText: AppStrings.ok,
    );
    if (mounted && date != null) {
      _selectedDate = date;
      _dateController.text = AppStrings.formatShortDate(date);
    }
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
        onPickDate: _pickDate,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel, style: textTheme.bodyLarge),
        ),
        AsyncActionBuilder(
          action: _save,
          builder: (_, save, busy) => ElevatedButton(
            onPressed: save,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            child: Text(busy ? AppStrings.saving : AppStrings.save),
          ),
        ),
      ],
    );
  }
}

class _AddVaccineFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController dateController;
  final TextEditingController vetController;
  final VoidCallback onPickDate;

  const _AddVaccineFormFields({
    required this.titleController,
    required this.dateController,
    required this.vetController,
    required this.onPickDate,
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
          readOnly: true,
          onTap: onPickDate,
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
