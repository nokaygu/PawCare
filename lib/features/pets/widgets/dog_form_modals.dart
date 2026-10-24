import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/models.dart';
import '../controller/pets_controller.dart';

class EditDogProfileModal extends StatefulWidget {
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
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) =>
          EditDogProfileModal(dog: dog, petsController: petsController),
    );
  }

  @override
  State<EditDogProfileModal> createState() => _EditDogProfileModalState();
}

class _EditDogProfileModalState extends State<EditDogProfileModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _microchipCtrl;
  late final TextEditingController _allergyCtrl;
  late final TextEditingController _behaviorCtrl;
  late final TextEditingController _clinicCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final d = widget.dog;
    _nameCtrl = TextEditingController(text: d.name);
    _breedCtrl = TextEditingController(text: d.breed);
    _ageCtrl = TextEditingController(text: '${d.ageYears}');
    _weightCtrl = TextEditingController(text: '${d.weightKg}');
    _genderCtrl = TextEditingController(text: d.gender);
    _microchipCtrl = TextEditingController(text: d.microchip);
    _allergyCtrl = TextEditingController(text: d.allergyNote);
    _behaviorCtrl = TextEditingController(text: d.behaviorNote);
    _clinicCtrl = TextEditingController(text: d.clinicName);
    _phoneCtrl = TextEditingController(text: d.clinicPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _genderCtrl.dispose();
    _microchipCtrl.dispose();
    _allergyCtrl.dispose();
    _behaviorCtrl.dispose();
    _clinicCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final updated = widget.dog.copyWith(
      name: _nameCtrl.text.trim().isEmpty
          ? widget.dog.name
          : _nameCtrl.text.trim(),
      breed: _breedCtrl.text.trim().isEmpty
          ? widget.dog.breed
          : _breedCtrl.text.trim(),
      ageYears: int.tryParse(_ageCtrl.text.trim()) ?? widget.dog.ageYears,
      weightKg: double.tryParse(_weightCtrl.text.trim()) ?? widget.dog.weightKg,
      gender: _genderCtrl.text.trim().isEmpty
          ? widget.dog.gender
          : _genderCtrl.text.trim(),
      microchip: _microchipCtrl.text.trim().isEmpty
          ? widget.dog.microchip
          : _microchipCtrl.text.trim(),
      allergyNote: _allergyCtrl.text.trim().isEmpty
          ? widget.dog.allergyNote
          : _allergyCtrl.text.trim(),
      behaviorNote: _behaviorCtrl.text.trim().isEmpty
          ? widget.dog.behaviorNote
          : _behaviorCtrl.text.trim(),
      clinicName: _clinicCtrl.text.trim().isEmpty
          ? widget.dog.clinicName
          : _clinicCtrl.text.trim(),
      clinicPhone: _phoneCtrl.text.trim().isEmpty
          ? widget.dog.clinicPhone
          : _phoneCtrl.text.trim(),
    );
    await widget.petsController.updateDog(updated);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.dogProfileUpdatedSnack(updated.name))),
    );
  }

  List<Widget> _actions(ColorScheme colors, TextTheme textTheme) => <Widget>[
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(AppStrings.cancel, style: textTheme.bodyLarge),
    ),
    ElevatedButton(
      onPressed: _saveChanges,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      child: const Text(AppStrings.save),
    ),
  ];

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
      title: Text(AppStrings.editDogModalTitle, style: textTheme.titleLarge),
      content: SingleChildScrollView(
        child: _DogFormFieldsColumn(
          nameCtrl: _nameCtrl,
          breedCtrl: _breedCtrl,
          ageCtrl: _ageCtrl,
          weightCtrl: _weightCtrl,
          genderCtrl: _genderCtrl,
          microchipCtrl: _microchipCtrl,
          allergyCtrl: _allergyCtrl,
          behaviorCtrl: _behaviorCtrl,
          clinicCtrl: _clinicCtrl,
          phoneCtrl: _phoneCtrl,
        ),
      ),
      actions: _actions(colors, textTheme),
    );
  }
}

class AddDogModal extends StatefulWidget {
  final PetsController petsController;

  const AddDogModal({super.key, required this.petsController});

  static Future<void> show(
    BuildContext context, {
    required PetsController petsController,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) => AddDogModal(petsController: petsController),
    );
  }

  @override
  State<AddDogModal> createState() => _AddDogModalState();
}

class _AddDogModalState extends State<AddDogModal> {
  final TextEditingController _nameCtrl = TextEditingController(
    text: AppStrings.defaultNewDogName,
  );
  final TextEditingController _breedCtrl = TextEditingController(
    text: AppStrings.defaultNewDogBreed,
  );
  final TextEditingController _ageCtrl = TextEditingController(
    text: AppStrings.defaultNewDogAge,
  );
  final TextEditingController _weightCtrl = TextEditingController(
    text: AppStrings.defaultNewDogWeight,
  );
  final TextEditingController _genderCtrl = TextEditingController(
    text: AppStrings.defaultNewDogGender,
  );
  final TextEditingController _microchipCtrl = TextEditingController(
    text: AppStrings.defaultNewDogMicrochip,
  );
  final TextEditingController _allergyCtrl = TextEditingController(
    text: AppStrings.defaultNewDogAllergy,
  );
  final TextEditingController _behaviorCtrl = TextEditingController(
    text: AppStrings.defaultNewDogBehavior,
  );
  final TextEditingController _clinicCtrl = TextEditingController(
    text: AppStrings.defaultNewDogClinic,
  );
  final TextEditingController _phoneCtrl = TextEditingController(
    text: AppStrings.defaultNewDogPhone,
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _genderCtrl.dispose();
    _microchipCtrl.dispose();
    _allergyCtrl.dispose();
    _behaviorCtrl.dispose();
    _clinicCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _createDog() async {
    await widget.petsController.addNewDog(
      name: _nameCtrl.text,
      breed: _breedCtrl.text,
      ageYears: int.tryParse(_ageCtrl.text.trim()) ?? 2,
      weightKg: double.tryParse(_weightCtrl.text.trim()) ?? 10.0,
      gender: _genderCtrl.text,
      microchip: _microchipCtrl.text,
      allergyNote: _allergyCtrl.text,
      behaviorNote: _behaviorCtrl.text,
      clinicName: _clinicCtrl.text,
      clinicPhone: _phoneCtrl.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.dogAddedSnack(widget.petsController.currentDog.name),
        ),
      ),
    );
  }

  List<Widget> _actions(ColorScheme colors, TextTheme textTheme) => <Widget>[
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(AppStrings.cancel, style: textTheme.bodyLarge),
    ),
    ElevatedButton(
      onPressed: _createDog,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      child: const Text(AppStrings.saveDogButton),
    ),
  ];

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
      title: Text(AppStrings.addNewDogButton, style: textTheme.titleLarge),
      content: SingleChildScrollView(
        child: _DogFormFieldsColumn(
          nameCtrl: _nameCtrl,
          breedCtrl: _breedCtrl,
          ageCtrl: _ageCtrl,
          weightCtrl: _weightCtrl,
          genderCtrl: _genderCtrl,
          microchipCtrl: _microchipCtrl,
          allergyCtrl: _allergyCtrl,
          behaviorCtrl: _behaviorCtrl,
          clinicCtrl: _clinicCtrl,
          phoneCtrl: _phoneCtrl,
        ),
      ),
      actions: _actions(colors, textTheme),
    );
  }
}

class _DogFormFieldsColumn extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController breedCtrl;
  final TextEditingController ageCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController genderCtrl;
  final TextEditingController microchipCtrl;
  final TextEditingController allergyCtrl;
  final TextEditingController behaviorCtrl;
  final TextEditingController clinicCtrl;
  final TextEditingController phoneCtrl;

  const _DogFormFieldsColumn({
    required this.nameCtrl,
    required this.breedCtrl,
    required this.ageCtrl,
    required this.weightCtrl,
    required this.genderCtrl,
    required this.microchipCtrl,
    required this.allergyCtrl,
    required this.behaviorCtrl,
    required this.clinicCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _BasicIdentityFields(
          nameCtrl: nameCtrl,
          breedCtrl: breedCtrl,
          ageCtrl: ageCtrl,
          weightCtrl: weightCtrl,
          genderCtrl: genderCtrl,
          microchipCtrl: microchipCtrl,
        ),
        const SizedBox(height: AppDimens.p10),
        _HealthAndClinicFields(
          allergyCtrl: allergyCtrl,
          behaviorCtrl: behaviorCtrl,
          clinicCtrl: clinicCtrl,
          phoneCtrl: phoneCtrl,
        ),
      ],
    );
  }
}

class _BasicIdentityFields extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController breedCtrl;
  final TextEditingController ageCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController genderCtrl;
  final TextEditingController microchipCtrl;

  const _BasicIdentityFields({
    required this.nameCtrl,
    required this.breedCtrl,
    required this.ageCtrl,
    required this.weightCtrl,
    required this.genderCtrl,
    required this.microchipCtrl,
  });

  Widget _ageWeightRow() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: ageCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppStrings.statAgeLabel,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.p10),
        Expanded(
          child: TextField(
            controller: weightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: AppStrings.fieldWeightKg,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: AppStrings.fieldDogName),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: breedCtrl,
          decoration: const InputDecoration(labelText: AppStrings.fieldBreed),
        ),
        const SizedBox(height: AppDimens.p10),
        _ageWeightRow(),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: genderCtrl,
          decoration: const InputDecoration(
            labelText: AppStrings.statGenderLabel,
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: microchipCtrl,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldMicrochip,
          ),
        ),
      ],
    );
  }
}

class _HealthAndClinicFields extends StatelessWidget {
  final TextEditingController allergyCtrl;
  final TextEditingController behaviorCtrl;
  final TextEditingController clinicCtrl;
  final TextEditingController phoneCtrl;

  const _HealthAndClinicFields({
    required this.allergyCtrl,
    required this.behaviorCtrl,
    required this.clinicCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: allergyCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldAllergyNote,
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: behaviorCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldBehaviorNote,
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: clinicCtrl,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldVetClinic,
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: phoneCtrl,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldClinicPhone,
          ),
        ),
      ],
    );
  }
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
          Icons.qr_code_2,
          size: AppDimens.splashLogoBox,
          color: colors.primary,
        ),
        const SizedBox(height: AppDimens.p12),
        Text(
          dog.microchip,
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
