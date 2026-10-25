import '../local/hive_boxes.dart';
import '../models/models.dart';
import 'settings_repository.dart';
import '../../core/constants/app_strings.dart';

class DogRepository {
  const DogRepository();

  List<Dog> getAllDogs() {
    final ownerId = const SettingsRepository().getOwnerId();
    return HiveBoxes.readRecords<Dog>(
      HiveBoxes.dogsBoxName,
      where: (raw) => raw['ownerId'] == ownerId,
    );
  }

  Dog getCurrentDog({List<Dog>? dogs}) {
    return findCurrentDog(dogs: dogs) ?? (throw StateError('No selected pet'));
  }

  Dog? findCurrentDog({List<Dog>? dogs}) {
    final availableDogs = dogs ?? getAllDogs();
    final activeId = const SettingsRepository().getActiveDogId();
    return availableDogs.where((d) => d.id == activeId).firstOrNull ??
        availableDogs.firstOrNull;
  }

  Future<void> setActiveDog(String dogId) async {
    _requireOwnedDog(dogId);
    await const SettingsRepository().setActiveDogId(dogId);
  }

  Future<void> saveDog(Dog dog) async {
    if (dog.ownerId != const SettingsRepository().getOwnerId()) {
      throw StateError('Pet belongs to another account');
    }
    final saved = HiveBoxes.getValue(HiveBoxes.dogsBoxName, dog.id);
    if (saved is Map && Dog.fromMap(saved).ownerId != dog.ownerId) {
      throw StateError('Pet ownership cannot be overwritten');
    }
    if (dog.name.trim().isEmpty ||
        dog.breed.trim().isEmpty ||
        dog.ageYears < 0 ||
        dog.ageYears > 50 ||
        !dog.weightKg.isFinite ||
        dog.weightKg <= 0 ||
        dog.weightKg > 1000) {
      throw ArgumentError(AppStrings.invalidPetFields);
    }
    if (dog.microchip.trim().isNotEmpty &&
        (saved is! Map || saved['microchip'] != dog.microchip) &&
        HiveBoxes.getValues(HiveBoxes.dogsBoxName).whereType<Map>().any(
          (other) =>
              other['id'] != dog.id &&
              other['ownerId'] == dog.ownerId &&
              (other['microchip'] is String ? other['microchip'] as String : '')
                      .trim() ==
                  dog.microchip.trim(),
        )) {
      throw ArgumentError(AppStrings.duplicateMicrochip);
    }
    await HiveBoxes.putValue(HiveBoxes.dogsBoxName, dog.id, dog.toMap());
  }

  Dog _requireOwnedDog(String dogId) {
    final dog = HiveBoxes.readRecord<Dog>(HiveBoxes.dogsBoxName, dogId);
    if (dog == null) throw StateError('Pet not found');
    if (dog.ownerId != const SettingsRepository().getOwnerId()) {
      throw StateError('Pet belongs to another account');
    }
    return dog;
  }

  Dog? getById(String dogId) {
    final dog = HiveBoxes.readRecord<Dog>(HiveBoxes.dogsBoxName, dogId);
    if (dog == null) return null;
    return dog.ownerId == const SettingsRepository().getOwnerId() ? dog : null;
  }

  /// Reference checks protect files shared with another account without exposing
  /// that account's pet records through the public pet list.
  bool isPhotoReferenced(String path) =>
      HiveBoxes.getValues(HiveBoxes.dogsBoxName)
          .any((raw) => raw is Map && raw['photoPath'] == path);

  Future<Dog> addVaccination(String dogId, Vaccination vaccination) async {
    final dog = _requireOwnedDog(dogId);
    final updatedVaccinations = <Vaccination>[vaccination, ...dog.vaccinations];
    final updatedDog = dog.copyWith(vaccinations: updatedVaccinations);
    await saveDog(updatedDog);
    return updatedDog;
  }

  Future<Dog> toggleVaccinationStatus(
    String dogId,
    String vaccineId, {
    DateTime? at,
  }) async {
    final dog = _requireOwnedDog(dogId);
    if (!dog.vaccinations.any((v) => v.id == vaccineId)) {
      throw StateError('Vaccination not found');
    }
    final updatedVaccinations = dog.vaccinations.map((v) {
      if (v.id != vaccineId) return v;
      final nextStatus = v.status == VaccineStatus.completed
          ? VaccineStatus.upcoming
          : VaccineStatus.completed;
      return v.copyWith(
        status: nextStatus,
        completedAt: nextStatus == VaccineStatus.completed
            ? (at ?? DateTime.now())
            : null,
        clearCompletion: nextStatus != VaccineStatus.completed,
      );
    }).toList();
    final updatedDog = dog.copyWith(vaccinations: updatedVaccinations);
    await saveDog(updatedDog);
    return updatedDog;
  }
}
