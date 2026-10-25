import '../../core/utils/image_storage_service.dart';
import '../../core/utils/record_id.dart';
import '../local/hive_boxes.dart';
import '../models/models.dart';
import 'booking_repository.dart';
import 'dog_repository.dart';
import 'settings_repository.dart';
import 'sitter_repository.dart';

/// Durable picker intent: a recovered photo belongs to its original pet/account.
class PetPhotoRecovery {
  static const pendingKey = 'pending_pet_photo';
  final ImageStorageService storage;
  final DogRepository dogs;
  final BookingRepository bookings;
  final SettingsRepository settings;
  PetPhotoRecovery({
    required this.storage,
    this.dogs = const DogRepository(),
    BookingRepository? bookings,
    this.settings = const SettingsRepository(),
  }) : bookings = bookings ?? BookingRepository();

  Future<String> begin(Dog dog) async {
    final id = RecordId.create('photo');
    await HiveBoxes.mutateValue(HiveBoxes.settingsBoxName, pendingKey, (raw) {
      if (raw != null) throw StateError('Photo selection already pending');
      return {'operationId': id, 'ownerId': dog.ownerId, 'petId': dog.id};
    });
    return id;
  }

  Future<void> stage(String operationId, String path) =>
      HiveBoxes.mutateValue(HiveBoxes.settingsBoxName, pendingKey, (raw) {
        if (raw is! Map || raw['operationId'] != operationId) {
          throw StateError('Photo operation changed');
        }
        return Map<dynamic, dynamic>.from(raw)..['path'] = path;
      });
  Future<void> complete(String operationId) async {
    final raw = HiveBoxes.getValue(HiveBoxes.settingsBoxName, pendingKey);
    if (raw is Map && raw['operationId'] == operationId) {
      await HiveBoxes.deleteValue(HiveBoxes.settingsBoxName, pendingKey);
    }
  }

  Future<void> _discardIfUnused(String path) async {
    if (dogs.isPhotoReferenced(path) ||
        bookings.isPhotoReferenced(path) ||
        const SitterRepository().isPhotoReferenced(path)) {
      return;
    }
    await storage.deletePetPhoto(path);
  }

  Future<bool> restore({
    int emptyResultRetries = 0,
    Duration retryDelay = const Duration(milliseconds: 100),
  }) async {
    if (emptyResultRetries < 0) throw ArgumentError.value(emptyResultRetries);
    final raw = HiveBoxes.getValue(HiveBoxes.settingsBoxName, pendingKey);
    final staged = raw is Map && raw['path'] is String
        ? raw['path'] as String
        : null;
    var recovered = await storage.recoverLostPetPhoto();
    // Android processes the returned URI off the main thread. An early empty
    // cache is not cancellation while that work is still settling.
    for (
      var attempt = 0;
      recovered == null &&
          staged == null &&
          raw is Map &&
          attempt < emptyResultRetries;
      attempt++
    ) {
      await Future<void>.delayed(retryDelay);
      recovered = await storage.recoverLostPetPhoto();
    }
    final path = staged ?? recovered;
    if (recovered != null && staged != null && recovered != staged) {
      await _discardIfUnused(recovered);
    }
    if (path == null) {
      if (raw is Map && raw['operationId'] is String) {
        await complete(raw['operationId'] as String);
      }
      return false;
    }
    if (raw is! Map ||
        raw['operationId'] is! String ||
        raw['petId'] is! String ||
        raw['ownerId'] != settings.getOwnerId()) {
      await _discardIfUnused(path);
      await HiveBoxes.deleteValue(HiveBoxes.settingsBoxName, pendingKey);
      return false;
    }
    final dog = dogs.getById(raw['petId'] as String);
    if (dog == null) {
      await _discardIfUnused(path);
      await complete(raw['operationId'] as String);
      return false;
    }
    await stage(raw['operationId'] as String, path);
    if (dog.photoPath != path) {
      await dogs.saveDog(dog.copyWith(photoPath: path));
      await _discardIfUnused(dog.photoPath);
    }
    await complete(raw['operationId'] as String);
    return true;
  }
}
