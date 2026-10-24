import '../local/hive_boxes.dart';
import '../local/hive_seed_data.dart';
import '../models/models.dart';
import 'settings_repository.dart';

class DogRepository {
  const DogRepository();

  List<Dog> getAllDogs() {
    final rawList = HiveBoxes.getValues(HiveBoxes.dogsBoxName);
    if (rawList.isEmpty) {
      return <Dog>[HiveSeedData.initialDog];
    }
    return rawList
        .map((e) => Dog.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  Dog getCurrentDog({List<Dog>? dogs}) {
    final availableDogs = dogs ?? getAllDogs();
    final activeId = const SettingsRepository().getActiveDogId();
    return availableDogs.firstWhere(
      (d) => d.id == activeId,
      orElse: () => availableDogs.first,
    );
  }

  Future<void> setActiveDog(String dogId) async {
    await const SettingsRepository().setActiveDogId(dogId);
  }

  Future<void> saveDog(Dog dog) async {
    await HiveBoxes.putValue(HiveBoxes.dogsBoxName, dog.id, dog.toMap());
  }

  Future<Dog> addVaccination(String dogId, Vaccination vaccination) async {
    final dog = getAllDogs().firstWhere(
      (d) => d.id == dogId,
      orElse: getCurrentDog,
    );
    final updatedVaccinations = <Vaccination>[vaccination, ...dog.vaccinations];
    final updatedDog = dog.copyWith(vaccinations: updatedVaccinations);
    await saveDog(updatedDog);
    return updatedDog;
  }

  Future<Dog> toggleVaccinationStatus(String dogId, String vaccineId) async {
    final dog = getAllDogs().firstWhere(
      (d) => d.id == dogId,
      orElse: getCurrentDog,
    );
    final updatedVaccinations = dog.vaccinations.map((v) {
      if (v.id != vaccineId) return v;
      final nextStatus = v.status == VaccineStatus.completed
          ? VaccineStatus.upcoming
          : VaccineStatus.completed;
      return v.copyWith(status: nextStatus);
    }).toList();
    final updatedDog = dog.copyWith(vaccinations: updatedVaccinations);
    await saveDog(updatedDog);
    return updatedDog;
  }
}
