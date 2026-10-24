import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/image_storage_service.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/dog_repository.dart';
import '../../notifications/controller/notifications_controller.dart';

class PetsController extends ValueNotifier<Dog> {
  final DogRepository _dogRepository;
  final BookingRepository _bookingRepository;
  final ImageStorageService _imageStorageService;
  final NotificationsController? notificationsController;
  List<Dog> _allDogs;

  factory PetsController({
    DogRepository? dogRepository,
    BookingRepository? bookingRepository,
    ImageStorageService? imageStorageService,
    NotificationsController? notificationsController,
  }) {
    final repository = dogRepository ?? const DogRepository();
    return PetsController._(
      repository,
      bookingRepository ?? const BookingRepository(),
      imageStorageService ?? ImageStorageService(),
      notificationsController,
      repository.getAllDogs(),
    );
  }

  PetsController._(
    this._dogRepository,
    this._bookingRepository,
    this._imageStorageService,
    this.notificationsController,
    List<Dog> dogs,
  ) : _allDogs = List<Dog>.unmodifiable(dogs),
      super(_dogRepository.getCurrentDog(dogs: dogs));

  Dog get currentDog => value;

  List<Dog> get allDogs => _allDogs;

  void refresh() {
    _allDogs = List<Dog>.unmodifiable(_dogRepository.getAllDogs());
    value = _dogRepository.getCurrentDog(dogs: _allDogs);
  }

  Future<void> selectDog(String dogId) async {
    final dog = _allDogs.where((dog) => dog.id == dogId).firstOrNull;
    if (dog == null) return;
    await _dogRepository.setActiveDog(dogId);
    value = dog;
  }

  void _cacheDog(Dog dog, {bool makeActive = false}) {
    final existingIndex = _allDogs.indexWhere((entry) => entry.id == dog.id);
    final dogs = List<Dog>.of(_allDogs);
    if (existingIndex == -1) {
      dogs.add(dog);
    } else {
      dogs[existingIndex] = dog;
    }
    _allDogs = List<Dog>.unmodifiable(dogs);
    if (makeActive || value.id == dog.id) {
      value = dog;
    } else {
      notifyListeners();
    }
  }

  Future<bool> pickAndUpdatePhoto() async {
    final dogId = value.id;
    final newPath = await _imageStorageService.pickAndSavePetPhoto();
    if (newPath == null) return false;
    final dog = _allDogs.firstWhere((entry) => entry.id == dogId);
    await _replacePhoto(dog, newPath, discardOnSaveFailure: true);
    return true;
  }

  Future<void> updatePhotoPath(String path) async {
    await _replacePhoto(value, path);
  }

  Future<void> _replacePhoto(
    Dog dog,
    String path, {
    bool discardOnSaveFailure = false,
  }) async {
    if (dog.photoPath == path) return;
    final updated = dog.copyWith(photoPath: path);
    try {
      await _dogRepository.saveDog(updated);
    } catch (_) {
      if (discardOnSaveFailure) {
        await _imageStorageService.deletePetPhoto(path);
      }
      rethrow;
    }
    _cacheDog(updated);
    final photoStillUsed =
        _allDogs.any((entry) => entry.photoPath == dog.photoPath) ||
        _bookingRepository.getAllBookings().any(
          (booking) => booking.petPhotoPath == dog.photoPath,
        );
    if (!photoStillUsed) {
      await _imageStorageService.deletePetPhoto(dog.photoPath);
    }
  }

  Future<void> updateDog(Dog updated) async {
    await _dogRepository.saveDog(updated);
    _cacheDog(updated);
    await notificationsController?.addNotification(
      title: AppStrings.notifDogUpdatedTitle,
      message: AppStrings.notifDogUpdatedBody(updated.name),
      type: NotificationType.vaccineReminder,
    );
  }

  Future<void> addNewDog({
    required String name,
    required String breed,
    required int ageYears,
    required double weightKg,
    required String gender,
    required String microchip,
    required String allergyNote,
    required String behaviorNote,
    required String clinicName,
    required String clinicPhone,
  }) async {
    final trimmedName = name.trim().isEmpty
        ? AppStrings.defaultNewDogName
        : name.trim();
    final newId = 'dog_${DateTime.now().microsecondsSinceEpoch}';
    final newDog = Dog(
      id: newId,
      name: trimmedName,
      breed: breed.trim().isEmpty ? AppStrings.fallbackBreed : breed.trim(),
      ageYears: ageYears <= 0 ? 2 : ageYears,
      weightKg: weightKg <= 0 ? 18.0 : weightKg,
      gender: gender.trim().isEmpty ? AppStrings.fallbackGender : gender.trim(),
      microchip: microchip.trim().isEmpty
          ? AppStrings.defaultNewDogMicrochip
          : microchip.trim(),
      photoPath: 'assets/images/barley.jpg',
      allergyNote: allergyNote.trim().isEmpty
          ? AppStrings.fallbackAllergy
          : allergyNote.trim(),
      behaviorNote: behaviorNote.trim().isEmpty
          ? AppStrings.fallbackBehavior
          : behaviorNote.trim(),
      clinicName: clinicName.trim().isEmpty
          ? AppStrings.defaultNewDogClinic
          : clinicName.trim(),
      clinicPhone: clinicPhone.trim().isEmpty
          ? AppStrings.defaultNewDogPhone
          : clinicPhone.trim(),
      vaccinations: <Vaccination>[
        Vaccination(
          id: 'v_init_${DateTime.now().microsecondsSinceEpoch}',
          title: AppStrings.initialVaccineTitle,
          dueDate: AppStrings.initialVaccineDueDate,
          status: VaccineStatus.upcoming,
          vetName: AppStrings.defaultVaccineVet,
        ),
      ],
    );
    await _dogRepository.saveDog(newDog);
    await _dogRepository.setActiveDog(newId);
    _cacheDog(newDog, makeActive: true);
    await notificationsController?.addNotification(
      title: AppStrings.notifDogAddedTitle,
      message: AppStrings.notifDogAddedBody(trimmedName, newDog.breed),
      type: NotificationType.vaccineReminder,
    );
  }

  Future<void> addVaccination({
    required String title,
    required String dueDate,
    required String vetName,
  }) async {
    if (title.trim().isEmpty) return;
    final newVaccine = Vaccination(
      id: 'v_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      dueDate: dueDate.trim().isEmpty
          ? AppStrings.fallbackVaccineDueDate
          : dueDate.trim(),
      status: VaccineStatus.upcoming,
      vetName: vetName.trim().isEmpty
          ? AppStrings.defaultVaccineVet
          : vetName.trim(),
    );
    final updatedDog = await _dogRepository.addVaccination(
      value.id,
      newVaccine,
    );
    _cacheDog(updatedDog);
    await notificationsController?.addNotification(
      title: AppStrings.notifVaccineAddedTitle,
      message: AppStrings.notifVaccineAddedBody(
        updatedDog.name,
        newVaccine.title,
        newVaccine.dueDate,
      ),
      type: NotificationType.vaccineReminder,
    );
  }

  Future<void> toggleVaccinationStatus(String vaccineId) async {
    final updatedDog = await _dogRepository.toggleVaccinationStatus(
      value.id,
      vaccineId,
    );
    _cacheDog(updatedDog);
  }
}
