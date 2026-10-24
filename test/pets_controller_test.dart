import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/core/utils/image_storage_service.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/dog_repository.dart';
import 'package:paw_care/features/pets/controller/pets_controller.dart';

class _CountingDogRepository extends DogRepository {
  int reads = 0;
  bool failWrites = false;

  @override
  List<Dog> getAllDogs() {
    reads++;
    return super.getAllDogs();
  }

  @override
  Future<void> saveDog(Dog dog) async {
    if (failWrites) throw StateError('Storage unavailable');
    await super.saveDog(dog);
  }
}

class _RecordingImageStorageService extends ImageStorageService {
  final List<String> deletedPaths = <String>[];
  String? pickedPath;
  Completer<String?>? pendingSelection;
  void Function(String)? onDelete;

  @override
  Future<String?> pickAndSavePetPhoto() async {
    return pendingSelection == null ? pickedPath : pendingSelection!.future;
  }

  @override
  Future<void> deletePetPhoto(String path) async {
    onDelete?.call(path);
    deletedPaths.add(path);
  }
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  test('Dog list reads are cached and saves update the cached dog', () async {
    final repository = _CountingDogRepository();
    final controller = PetsController(dogRepository: repository);
    addTearDown(controller.dispose);
    expect(repository.reads, 1);
    expect(identical(controller.allDogs, controller.allDogs), isTrue);
    expect(() => controller.allDogs.clear(), throwsUnsupportedError);
    expect(repository.reads, 1);

    await controller.updateDog(controller.currentDog.copyWith(name: 'Updated'));
    expect(controller.allDogs.single.name, 'Updated');
    expect(controller.currentDog.name, 'Updated');
    expect(repository.reads, 1);

    await repository.saveDog(controller.currentDog.copyWith(name: 'External'));
    expect(controller.currentDog.name, 'Updated');
    controller.refresh();
    expect(controller.currentDog.name, 'External');
    expect(controller.allDogs.single.name, 'External');
    expect(repository.reads, 2);
  });

  test('Vaccination edits refresh the cached dog list', () async {
    final controller = PetsController();
    addTearDown(controller.dispose);
    await controller.addVaccination(
      title: 'New vaccine',
      dueDate: '1 January 2027',
      vetName: 'Vet',
    );
    final vaccine = controller.currentDog.vaccinations.first;
    expect(controller.allDogs.single.vaccinations.first.id, vaccine.id);
    await controller.toggleVaccinationStatus(vaccine.id);
    expect(
      controller.allDogs.single.vaccinations.first.status,
      VaccineStatus.completed,
    );
  });

  test(
    'Adding and selecting dogs updates cached state without extra reads',
    () async {
      final repository = _CountingDogRepository();
      final controller = PetsController(dogRepository: repository);
      addTearDown(controller.dispose);
      await controller.addNewDog(
        name: 'Second dog',
        breed: 'Terrier',
        ageYears: 3,
        weightKg: 12,
        gender: 'Female',
        microchip: 'second_chip',
        allergyNote: '',
        behaviorNote: '',
        clinicName: '',
        clinicPhone: '',
      );
      expect(controller.allDogs, hasLength(2));
      expect(controller.currentDog.name, 'Second dog');
      await controller.selectDog(HiveSeedData.initialDog.id);
      expect(controller.currentDog.id, HiveSeedData.initialDog.id);
      await controller.selectDog('missing_dog');
      expect(controller.currentDog.id, HiveSeedData.initialDog.id);
      expect(repository.reads, 1);
    },
  );

  test('Photo replacement saves before removing the previous photo', () async {
    const repository = DogRepository();
    await repository.saveDog(
      HiveSeedData.initialDog.copyWith(photoPath: '/old.jpg'),
    );
    final images = _RecordingImageStorageService()..pickedPath = '/new.jpg';
    images.onDelete = (path) {
      expect(repository.getCurrentDog().photoPath, '/new.jpg');
    };
    final controller = PetsController(imageStorageService: images);
    addTearDown(controller.dispose);

    expect(await controller.pickAndUpdatePhoto(), isTrue);
    expect(controller.currentDog.photoPath, '/new.jpg');
    expect(controller.allDogs.single.photoPath, '/new.jpg');
    expect(images.deletedPaths, <String>['/old.jpg']);
    await controller.updatePhotoPath('/new.jpg');
    expect(images.deletedPaths, hasLength(1));
  });

  test(
    'Photo snapshots referenced by persisted bookings remain available',
    () async {
      const dogs = DogRepository();
      const bookings = BookingRepository();
      await dogs.saveDog(
        HiveSeedData.initialDog.copyWith(photoPath: '/booked_photo.jpg'),
      );
      await bookings.addBooking(
        HiveSeedData.createInitialBookings().first.copyWith(
          id: 'snapshot_booking',
          petPhotoPath: '/booked_photo.jpg',
        ),
      );
      final images = _RecordingImageStorageService();
      final controller = PetsController(
        imageStorageService: images,
        bookingRepository: bookings,
      );
      addTearDown(controller.dispose);

      await controller.updatePhotoPath('/unreferenced_photo.jpg');

      expect(images.deletedPaths, isEmpty);
      expect(
        bookings
            .getAllBookings()
            .firstWhere((booking) => booking.id == 'snapshot_booking')
            .petPhotoPath,
        '/booked_photo.jpg',
      );

      await controller.updatePhotoPath('/latest_photo.jpg');

      expect(images.deletedPaths, <String>['/unreferenced_photo.jpg']);
      expect(controller.currentDog.photoPath, '/latest_photo.jpg');
      expect(dogs.getCurrentDog().photoPath, '/latest_photo.jpg');
    },
  );

  test(
    'A failed photo save retains the old photo and removes the unused copy',
    () async {
      final repository = _CountingDogRepository();
      await repository.saveDog(
        HiveSeedData.initialDog.copyWith(photoPath: '/old.jpg'),
      );
      final images = _RecordingImageStorageService()..pickedPath = '/new.jpg';
      final controller = PetsController(
        dogRepository: repository,
        imageStorageService: images,
      );
      addTearDown(controller.dispose);
      repository.failWrites = true;

      await expectLater(controller.pickAndUpdatePhoto(), throwsStateError);
      expect(controller.currentDog.photoPath, '/old.jpg');
      expect(images.deletedPaths, <String>['/new.jpg']);
    },
  );

  test(
    'Selecting another dog during image selection updates the intended dog',
    () async {
      const repository = DogRepository();
      await repository.saveDog(
        HiveSeedData.initialDog.copyWith(id: 'dog_second'),
      );
      final images = _RecordingImageStorageService()
        ..pendingSelection = Completer<String?>();
      final controller = PetsController(imageStorageService: images);
      addTearDown(controller.dispose);
      final selection = controller.pickAndUpdatePhoto();
      await controller.selectDog('dog_second');
      images.pendingSelection!.complete('/selected.jpg');
      await selection;

      expect(controller.currentDog.id, 'dog_second');
      expect(
        controller.currentDog.photoPath,
        HiveSeedData.initialDog.photoPath,
      );
      expect(
        controller.allDogs
            .firstWhere((dog) => dog.id == HiveSeedData.initialDog.id)
            .photoPath,
        '/selected.jpg',
      );
      expect(images.deletedPaths, isEmpty);
    },
  );
}
