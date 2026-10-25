import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../data/models/models.dart';
import '../controller/pets_controller.dart';

enum _PetField {
  name,
  breed,
  age,
  weight,
  gender,
  microchip,
  allergy,
  behavior,
  clinic,
  phone,
  plan,
  vet;

  String get label => switch (this) {
    name => AppStrings.fieldDogName,
    breed => AppStrings.fieldBreed,
    age => AppStrings.statAgeLabel,
    weight => AppStrings.fieldWeightKg,
    gender => AppStrings.statGenderLabel,
    microchip => AppStrings.fieldMicrochip,
    allergy => AppStrings.fieldAllergyNote,
    behavior => AppStrings.fieldBehaviorNote,
    clinic => AppStrings.fieldVetClinic,
    phone => AppStrings.fieldClinicPhone,
    plan => AppStrings.nutritionPlanLabel,
    vet => AppStrings.veterinarianNameLabel,
  };

  String initial(Dog? dog) {
    if (dog == null) return '';
    return switch (this) {
      name => dog.name,
      breed => dog.breed,
      age => dog.ageYears.toString(),
      weight => dog.weightKg.toString(),
      gender => dog.gender,
      microchip => dog.microchip,
      allergy => dog.allergyNote,
      behavior => dog.behaviorNote,
      clinic => dog.clinicName,
      phone => dog.clinicPhone,
      plan => dog.nutritionPlan,
      vet => dog.veterinarianName,
    };
  }
}

class DogEditorModal extends StatefulWidget {
  final PetsController controller;
  final Dog? initialDog;
  const DogEditorModal({super.key, required this.controller, this.initialDog});
  @override
  State<DogEditorModal> createState() => _DogEditorModalState();
}

class _DogEditorModalState extends State<DogEditorModal> {
  late final Map<_PetField, TextEditingController> _fields;

  @override
  void initState() {
    super.initState();
    _fields = {
      for (final field in _PetField.values)
        field: TextEditingController(text: field.initial(widget.initialDog)),
    };
  }

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  String _text(_PetField field) => _fields[field]!.text.trim();

  Future<void> _save() async {
    final age = int.tryParse(_text(_PetField.age));
    final weight = Money.parse(_text(_PetField.weight));
    if (age == null || weight == null) {
      throw ArgumentError(AppStrings.invalidPetFields);
    }
    final initial = widget.initialDog;
    if (initial == null) {
      await widget.controller.addNewDog(
        name: _text(_PetField.name),
        breed: _text(_PetField.breed),
        ageYears: age,
        weightKg: weight,
        gender: _text(_PetField.gender),
        microchip: _text(_PetField.microchip),
        allergyNote: _text(_PetField.allergy),
        behaviorNote: _text(_PetField.behavior),
        clinicName: _text(_PetField.clinic),
        clinicPhone: _text(_PetField.phone),
        nutritionPlan: _text(_PetField.plan),
        veterinarianName: _text(_PetField.vet),
      );
    } else {
      final current = widget.controller.allDogs
          .where((dog) => dog.id == initial.id)
          .firstOrNull;
      if (current == null) throw StateError('Pet unavailable');
      await widget.controller.updateDog(
        current.copyWith(
          name: _text(_PetField.name),
          breed: _text(_PetField.breed),
          ageYears: age,
          weightKg: weight,
          gender: _text(_PetField.gender),
          microchip: _text(_PetField.microchip),
          allergyNote: _text(_PetField.allergy),
          behaviorNote: _text(_PetField.behavior),
          clinicName: _text(_PetField.clinic),
          clinicPhone: _text(_PetField.phone),
          nutritionPlan: _text(_PetField.plan),
          veterinarianName: _text(_PetField.vet),
        ),
      );
    }
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.controller.lastWarning ??
              (initial == null
                  ? AppStrings.dogAddedSnack(_text(_PetField.name))
                  : AppStrings.dogProfileUpdatedSnack(_text(_PetField.name))),
        ),
      ),
    );
  }

  Widget _field(_PetField field) => TextField(
    controller: _fields[field],
    keyboardType: switch (field) {
      _PetField.age => TextInputType.number,
      _PetField.weight => const TextInputType.numberWithOptions(decimal: true),
      _PetField.phone => TextInputType.phone,
      _ => TextInputType.text,
    },
    maxLines:
        field == _PetField.plan ||
            field == _PetField.allergy ||
            field == _PetField.behavior
        ? 3
        : 1,
    decoration: InputDecoration(labelText: field.label),
  );

  Widget _form() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _field(_PetField.name),
      const SizedBox(height: AppDimens.p10),
      _field(_PetField.breed),
      const SizedBox(height: AppDimens.p10),
      Row(
        children: [
          Expanded(child: _field(_PetField.age)),
          const SizedBox(width: AppDimens.p10),
          Expanded(child: _field(_PetField.weight)),
        ],
      ),
      for (final field in _PetField.values.skip(4)) ...[
        const SizedBox(height: AppDimens.p10),
        _field(field),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: context.pawTheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
    ),
    title: Text(
      widget.initialDog == null
          ? AppStrings.addNewDogButton
          : AppStrings.editDogModalTitle,
      style: context.pawTextTheme.titleLarge,
    ),
    content: SingleChildScrollView(child: _form()),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppStrings.cancel),
      ),
      AsyncActionBuilder(
        action: _save,
        builder: (_, save, busy) => ElevatedButton(
          onPressed: save,
          child: Text(busy ? AppStrings.saving : AppStrings.save),
        ),
      ),
    ],
  );
}
