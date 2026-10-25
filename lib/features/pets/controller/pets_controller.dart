import '../../../core/constants/app_strings.dart';
import '../../../core/utils/lifecycle_notifier.dart';
import '../../../core/utils/record_id.dart';
import '../../../core/utils/image_storage_service.dart';
import '../../../data/models/models.dart';
import '../../../data/models/calendar_date.dart';
import '../../../data/models/health_summary.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/dog_repository.dart';
import '../../../data/repositories/pet_photo_recovery.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';
import '../../notifications/controller/notifications_controller.dart';

class PetsController extends LifecycleNotifier<Dog?> {
  final DogRepository _dogRepository;
  final BookingRepository _bookingRepository;
  final ImageStorageService _imageStorageService;
  final NotificationsController? notificationsController;
  List<Dog> _allDogs;
  final DateTime Function() _now;
  String? lastWarning;
  late HealthSummary healthSummary;
  late final PetPhotoRecovery _photoRecovery = PetPhotoRecovery(
    storage: _imageStorageService,
    dogs: _dogRepository,
    bookings: _bookingRepository,
  );

  factory PetsController({
    DogRepository? dogRepository,
    BookingRepository? bookingRepository,
    ImageStorageService? imageStorageService,
    NotificationsController? notificationsController,
    DateTime Function()? now,
  }) {
    final repository = dogRepository ?? const DogRepository();
    return PetsController._(
      repository,
      bookingRepository ?? BookingRepository(),
      imageStorageService ?? ImageStorageService(),
      notificationsController,
      repository.getAllDogs(),
      now ?? DateTime.now,
    );
  }

  PetsController._(
    this._dogRepository,
    this._bookingRepository,
    this._imageStorageService,
    this.notificationsController,
    List<Dog> dogs,
    this._now,
  ) : _allDogs = List<Dog>.unmodifiable(dogs),
      super(_dogRepository.findCurrentDog(dogs: dogs)) {
    healthSummary = HealthSummary.forDog(value, _now());
  }

  @override
  set value(Dog? dog) {
    if (isDisposed ||
        (dog != null &&
            dog.ownerId != const SettingsRepository().getOwnerId())) {
      return;
    }
    healthSummary = HealthSummary.forDog(dog, _now());
    super.value = dog;
  }

  void refreshTime() {
    healthSummary = HealthSummary.forDog(value, _now());
    notifyListeners();
  }

  Dog get currentDog => value ?? (throw StateError('No selected pet'));
  bool get hasDog => value != null;

  List<Dog> get allDogs => _allDogs;

  void refresh() {
    _allDogs = List<Dog>.unmodifiable(_dogRepository.getAllDogs());
    value = _dogRepository.findCurrentDog(dogs: _allDogs);
  }

  Future<void> selectDog(String dogId) async {
    final dog = _allDogs.where((dog) => dog.id == dogId).firstOrNull;
    if (dog == null) return;
    await _dogRepository.setActiveDog(dogId);
    if (isDisposed || const SettingsRepository().getOwnerId() != dog.ownerId) {
      return;
    }
    value = dog;
  }

  void _cacheDog(Dog dog, {bool makeActive = false}) {
    if (isDisposed || dog.ownerId != const SettingsRepository().getOwnerId()) {
      return;
    }
    final existingIndex = _allDogs.indexWhere((entry) => entry.id == dog.id);
    final dogs = List<Dog>.of(_allDogs);
    if (existingIndex == -1) {
      dogs.add(dog);
    } else {
      dogs[existingIndex] = dog;
    }
    _allDogs = List<Dog>.unmodifiable(dogs);
    if (makeActive || value?.id == dog.id) {
      value = dog;
    } else {
      notifyListeners();
    }
  }

  Future<bool> pickAndUpdatePhoto() async {
    if (!hasDog || isDisposed) return false;
    return runExclusive(() async {
      lastWarning = null;
      final dogId = currentDog.id;
      final ownerId = currentDog.ownerId;
      final operationId = await _photoRecovery.begin(currentDog);
      String? newPath;
      try {
        newPath = await _imageStorageService.pickAndSavePetPhoto();
        if (newPath == null) {
          await _photoRecovery.complete(operationId);
          return false;
        }
        await _photoRecovery.stage(operationId, newPath);
        if (isDisposed || const SettingsRepository().getOwnerId() != ownerId) {
          if (!_dogRepository.isPhotoReferenced(newPath) &&
              !_bookingRepository.isPhotoReferenced(newPath) &&
              !const SitterRepository().isPhotoReferenced(newPath)) {
            await _imageStorageService.deletePetPhoto(newPath);
          }
          await _photoRecovery.complete(operationId);
          return false;
        }
        final dog = _allDogs.firstWhere((entry) => entry.id == dogId);
        await _replacePhoto(dog, newPath);
        try {
          await _photoRecovery.complete(operationId);
        } catch (_) {
          lastWarning = AppStrings.photoIntentCleanupFailed;
        }
        return true;
      } catch (_) {
        if (newPath != null &&
            !_dogRepository.isPhotoReferenced(newPath) &&
            !_bookingRepository.isPhotoReferenced(newPath) &&
            !const SitterRepository().isPhotoReferenced(newPath)) {
          await _imageStorageService.deletePetPhoto(newPath);
        }
        await _photoRecovery.complete(operationId);
        rethrow;
      }
    });
  }

  Future<void> updatePhotoPath(String path) async {
    await runExclusive(() => _replacePhoto(currentDog, path));
  }

  Future<void> _replacePhoto(Dog dog, String path) async {
    if (dog.photoPath == path) return;
    final updated = dog.copyWith(photoPath: path);
    await _dogRepository.saveDog(updated);
    _cacheDog(updated);
    final photoStillUsed =
        _dogRepository.isPhotoReferenced(dog.photoPath) ||
        _bookingRepository.isPhotoReferenced(dog.photoPath) ||
        const SitterRepository().isPhotoReferenced(dog.photoPath);
    if (!photoStillUsed) {
      try {
        await _imageStorageService.deletePetPhoto(dog.photoPath);
      } catch (_) {
        lastWarning = AppStrings.photoCleanupFailed;
      }
    }
  }

  Future<void> updateDog(Dog updated) async {
    await runExclusive(() async {
      await _dogRepository.saveDog(updated);
      _cacheDog(updated);
      await _notify(
        title: AppStrings.notifDogUpdatedTitle,
        message: AppStrings.notifDogUpdatedBody(updated.name),
        type: NotificationType.vaccineReminder,
        recipientId: updated.ownerId,
        recipientRole: UserRole.owner,
      );
    });
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
    String nutritionPlan = '',
    String veterinarianName = '',
  }) async {
    await runExclusive(() async {
      final trimmedName = name.trim();
      final newId = RecordId.create('dog');
      final newDog = Dog(
        id: newId,
        ownerId: const SettingsRepository().getOwnerId(),
        name: trimmedName,
        breed: breed.trim(),
        ageYears: ageYears,
        weightKg: weightKg,
        gender: gender.trim(),
        microchip: microchip.trim(),
        photoPath: '',
        allergyNote: allergyNote.trim(),
        behaviorNote: behaviorNote.trim(),
        clinicName: clinicName.trim(),
        clinicPhone: clinicPhone.trim(),
        nutritionPlan: nutritionPlan.trim(),
        veterinarianName: veterinarianName.trim(),
        vaccinations: const [],
      );
      await _dogRepository.saveDog(newDog);
      await _dogRepository.setActiveDog(newId);
      _cacheDog(newDog, makeActive: true);
      await _notify(
        title: AppStrings.notifDogAddedTitle,
        message: AppStrings.notifDogAddedBody(trimmedName, newDog.breed),
        type: NotificationType.vaccineReminder,
        recipientId: newDog.ownerId,
        recipientRole: UserRole.owner,
      );
    });
  }

  Future<void> addVaccination({
    required String title,
    required DateTime dueAt,
    required String vetName,
  }) async {
    await runExclusive(() async {
      if (title.trim().isEmpty) {
        throw ArgumentError(AppStrings.authErrorEmptyFields);
      }
      if (dueAt.year < 1900 || dueAt.year > 2200) {
        throw ArgumentError(AppStrings.invalidVaccineDate);
      }
      final due = CalendarDate.day(dueAt);
      final newVaccine = Vaccination(
        id: RecordId.create('v'),
        title: title.trim(),
        dueAt: due,
        status: due.isBefore(CalendarDate.day(_now()))
            ? VaccineStatus.overdue
            : VaccineStatus.upcoming,
        vetName: vetName.trim(),
      );
      final updatedDog = await _dogRepository.addVaccination(
        currentDog.id,
        newVaccine,
      );
      _cacheDog(updatedDog);
      await _notify(
        title: AppStrings.notifVaccineAddedTitle,
        message: AppStrings.notifVaccineAddedBody(
          updatedDog.name,
          newVaccine.title,
          newVaccine.dueDate,
        ),
        type: NotificationType.vaccineReminder,
        recipientId: updatedDog.ownerId,
        recipientRole: UserRole.owner,
      );
    });
  }

  Future<void> _notify({
    required String title,
    required String message,
    required NotificationType type,
    required String recipientId,
    required UserRole recipientRole,
  }) async {
    lastWarning = null;
    try {
      await notificationsController?.addNotification(
        title: title,
        message: message,
        type: type,
        recipientId: recipientId,
        recipientRole: recipientRole,
      );
    } catch (_) {
      lastWarning = AppStrings.notificationDeliveryFailed;
    }
  }

  Future<void> toggleVaccinationStatus(String vaccineId) async {
    await runExclusive(() async {
      final updatedDog = await _dogRepository.toggleVaccinationStatus(
        currentDog.id,
        vaccineId,
        at: _now(),
      );
      _cacheDog(updatedDog);
    });
  }
}
