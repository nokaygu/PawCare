import 'package:paw_care/features/provider/controller/provider_controller.dart';
import 'package:paw_care/features/provider/view/sitter_dashboard_screen.dart';
import 'package:paw_care/features/provider/widgets/sitter_sub_tabs.dart';
import 'package:paw_care/core/theme/app_theme.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/app/bootstrap.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/utils/image_storage_service.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/local/history_maintenance.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/dog_repository.dart';
import 'package:paw_care/data/repositories/notification_repository.dart';
import 'package:paw_care/data/repositories/pet_photo_recovery.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/notifications/controller/notifications_controller.dart';
import 'package:paw_care/features/onboarding/view/welcome_screen.dart';
import 'package:paw_care/features/pets/controller/pets_controller.dart';
import 'package:paw_care/features/splash/view/splash_screen.dart';

class _LostPhoto extends ImageStorageService {
  String? lost;
  final deleted = <String>[];
  @override
  Future<String?> recoverLostPetPhoto() async {
    final result = lost;
    lost = null;
    return result;
  }

  @override
  Future<String?> pickAndSavePetPhoto() async => null;
  @override
  Future<void> deletePetPhoto(String path) async {
    deleted.add(path);
  }
}

class _DelayedLostPhoto extends _LostPhoto {
  int calls = 0;
  final Future<void> Function(int)? beforeResult;
  _DelayedLostPhoto({this.beforeResult});
  @override
  Future<String?> recoverLostPetPhoto() async {
    calls++;
    await beforeResult?.call(calls);
    return calls < 3 ? null : super.recoverLostPetPhoto();
  }
}

Future<void> _withHive(Future<void> Function() action) async {
  final directory = await Directory.systemTemp.createTemp('pawcare_recovery_');
  try {
    Hive.init(directory.path);
    await HiveBoxes.openAndSeedBoxes();
    await action();
  } finally {
    await Hive.close();
    HiveBoxes.clearFallbackMemory();
    await directory.delete(recursive: true);
  }
}

NotificationItem _notice(
  String id, {
  required bool read,
  required DateTime at,
  String owner = HiveSeedData.demoOwnerId,
}) => NotificationItem(
  id: id,
  title: id,
  message: 'History',
  timeLabel: '',
  type: NotificationType.bookingCreated,
  isRead: read,
  createdAt: at,
  recipientId: owner,
  recipientRole: UserRole.owner,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);
  test('Malformed booking does not hide valid records and its original survives quarantine/restart', () async {
    await _withHive(() async {
      final box = Hive.box<dynamic>(HiveBoxes.bookingsBoxName);
      final raw = HiveSeedData.createInitialBookings().first.toMap()
        ..['id'] = 'corrupt'
        ..['startDate'] = 'broken';
      await HiveBoxes.putValue(HiveBoxes.bookingsBoxName, 'corrupt', raw);
      expect(BookingRepository().getAllBookings(), hasLength(2));
      expect(BookingRepository().getById('corrupt'), isNull);
      await HiveBoxes.openAndSeedBoxes();
      final copy = await HiveBoxes.getHistoryValue(
        HiveBoxes.quarantineBoxName,
        '${HiveBoxes.bookingsBoxName}/corrupt',
      );
      expect(copy['raw'], raw);
      expect(box.get('corrupt'), raw);
      expect(HiveBoxes.issues, hasLength(1));
      await Hive.close();
      await HiveBoxes.openAndSeedBoxes();
      expect(BookingRepository().getAllBookings(), hasLength(2));
      expect(HiveBoxes.issues, hasLength(1));
    });
  });
  test('Missing dates, wrong field types and malformed pets/listings/notifications are isolated', () async {
    final badBooking = HiveSeedData.createInitialBookings().first.toMap()
      ..['id'] = 'bad_date'
      ..remove('endDate');
    await HiveBoxes.putValue(HiveBoxes.bookingsBoxName, 'bad_date', badBooking);
    await HiveBoxes.putValue(HiveBoxes.dogsBoxName, 'bad_pet', {
      'id': 'bad_pet',
      'ownerId': HiveSeedData.demoOwnerId,
      'weightKg': 'bad',
    });
    await HiveBoxes.putValue(HiveBoxes.sittersBoxName, 'bad_sitter', {
      'id': 'bad_sitter',
      'rating': 'bad',
    });
    await HiveBoxes.putValue(HiveBoxes.notificationsBoxName, 'bad_notice', {
      'id': 'bad_notice',
      'recipientId': HiveSeedData.demoOwnerId,
      'recipientRole': UserRole.owner.name,
      'title': 4,
    });
    expect(BookingRepository().getAllBookings(), hasLength(2));
    expect(const DogRepository().getAllDogs(), hasLength(1));
    expect(const SitterRepository().getAllSitters(), hasLength(3));
    expect(const NotificationRepository().getAllNotifications(), hasLength(4));
    expect(HiveBoxes.issues, hasLength(4));
  });
  test('Invalid theme settings fail opening explicitly, preserve data and retry after repair', () async {
    await _withHive(() async {
      final box = Hive.box<dynamic>(HiveBoxes.settingsBoxName);
      await box.put('is_dark_mode', 'invalid');
      await expectLater(HiveBoxes.openAndSeedBoxes(), throwsFormatException);
      expect(box.get('is_dark_mode'), 'invalid');
      expect(
        (await HiveBoxes.getHistoryValue(
          HiveBoxes.quarantineBoxName,
          '${HiveBoxes.settingsBoxName}/is_dark_mode',
        ))['raw'],
        'invalid',
      );
      await box.put('is_dark_mode', false);
      await HiveBoxes.openAndSeedBoxes();
      expect(const SettingsRepository().getIsDarkMode(), isFalse);
    });
  });
  test('Persistent mode never silently falls back to demo memory after a box closes', () async {
    await _withHive(() async {
      await Hive.box<dynamic>(HiveBoxes.bookingsBoxName).close();
      expect(() => BookingRepository().getAllBookings(), throwsStateError);
    });
  });
  test(
    'Opening current storage does not rewrite settings or entity records',
    () async {
      await _withHive(() async {
        final events = <BoxEvent>[];
        final settings = Hive.box<dynamic>(HiveBoxes.settingsBoxName);
        final subscription = settings.watch().listen(events.add);
        final before = {
          for (final box in [
            HiveBoxes.dogsBoxName,
            HiveBoxes.sittersBoxName,
            HiveBoxes.bookingsBoxName,
          ])
            box: Hive.box<dynamic>(box).toMap(),
        };
        await HiveBoxes.openAndSeedBoxes();
        for (final entry in before.entries) {
          expect(Hive.box<dynamic>(entry.key).toMap(), entry.value);
        }
        await Future<void>.delayed(Duration.zero);
        expect(events, isEmpty);
        await subscription.cancel();
      });
    },
  );
  testWidgets(
    'Opening shows loading, offers retry on failure, then finishes splash automatically',
    (tester) async {
      final gate = Completer<void>();
      var attempts = 0;
      await tester.pumpWidget(
        PawCareBootstrap(
          initialize: () async {
            attempts++;
            if (attempts == 1) {
              await gate.future;
              throw StateError('Disk');
            }
          },
        ),
      );
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
      gate.complete();
      await tester.pump();
      await tester.pump();
      expect(find.text(AppStrings.startupErrorTitle), findsOneWidget);
      await tester.tap(find.text(AppStrings.retry));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(WelcomeScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  test('First launch welcome is persisted and returning launch resumes the chosen role', () async {
    final first = AppRouter(respectFirstLaunch: true);
    expect(first.value.showingWelcome, isTrue);
    await first.setRole(UserRole.sitter);
    first.dispose();
    final next = AppRouter(respectFirstLaunch: true);
    expect(next.value.showingWelcome, isFalse);
    expect(next.role, UserRole.sitter);
    next.dispose();
  });
  test(
    'Lost photo targets the original pet even when another pet is selected',
    () async {
      const dogs = DogRepository();
      final original = dogs.getCurrentDog();
      await dogs.saveDog(original.copyWith(id: 'second', microchip: ''));
      final storage = _LostPhoto()..lost = '/recovered.jpg';
      final recovery = PetPhotoRecovery(storage: storage);
      await recovery.begin(original);
      await dogs.setActiveDog('second');
      expect(await recovery.restore(), isTrue);
      expect(dogs.getById(original.id)!.photoPath, '/recovered.jpg');
      expect(dogs.getCurrentDog().id, 'second');
      expect(dogs.getCurrentDog().photoPath, original.photoPath);
      expect(
        HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          PetPhotoRecovery.pendingKey,
        ),
        isNull,
      );
    },
  );
  test('Recovered result never moves to a different owner and its unused copy is discarded', () async {
    final storage = _LostPhoto()..lost = '/recovered.jpg';
    final recovery = PetPhotoRecovery(storage: storage);
    await recovery.begin(const DogRepository().getCurrentDog());
    await const SettingsRepository().activateOwner(email: 'other@example.com');
    expect(await recovery.restore(), isFalse);
    expect(storage.deleted, ['/recovered.jpg']);
    expect(const DogRepository().getAllDogs(), isEmpty);
  });
  test('An initially empty Android result preserves its target until the delayed URI is available', () async {
    final original = const DogRepository().getCurrentDog();
    final storage = _DelayedLostPhoto(
      beforeResult: (attempt) async {
        expect(
          HiveBoxes.getValue(
            HiveBoxes.settingsBoxName,
            PetPhotoRecovery.pendingKey,
          ),
          isNotNull,
        );
      },
    )..lost = '/delayed.jpg';
    final recovery = PetPhotoRecovery(storage: storage);
    await recovery.begin(original);
    expect(
      await recovery.restore(emptyResultRetries: 3, retryDelay: Duration.zero),
      isTrue,
    );
    expect(storage.calls, 3);
    expect(
      const DogRepository().getById(original.id)!.photoPath,
      '/delayed.jpg',
    );
    expect(
      HiveBoxes.getValue(
        HiveBoxes.settingsBoxName,
        PetPhotoRecovery.pendingKey,
      ),
      isNull,
    );
  });
  test('Account changes while a delayed picker result is settling never receive the previous owner photo', () async {
    final storage = _DelayedLostPhoto(
      beforeResult: (attempt) async {
        if (attempt == 2) {
          await const SettingsRepository().activateOwner(
            email: 'delayed-other@example.com',
          );
        }
      },
    )..lost = '/wrong-owner.jpg';
    final recovery = PetPhotoRecovery(storage: storage);
    await recovery.begin(const DogRepository().getCurrentDog());
    expect(
      await recovery.restore(emptyResultRetries: 3, retryDelay: Duration.zero),
      isFalse,
    );
    expect(storage.deleted, ['/wrong-owner.jpg']);
    expect(const DogRepository().getAllDogs(), isEmpty);
  });
  test('An empty result after bounded retries clears a cancelled recovered operation', () async {
    final storage = _DelayedLostPhoto();
    final recovery = PetPhotoRecovery(storage: storage);
    await recovery.begin(const DogRepository().getCurrentDog());
    expect(
      await recovery.restore(emptyResultRetries: 3, retryDelay: Duration.zero),
      isFalse,
    );
    expect(storage.calls, 4);
    expect(
      HiveBoxes.getValue(
        HiveBoxes.settingsBoxName,
        PetPhotoRecovery.pendingKey,
      ),
      isNull,
    );
  });
  test(
    'A removed target and a result without an intent never update another pet',
    () async {
      final storage = _LostPhoto()..lost = '/recovered.jpg';
      final recovery = PetPhotoRecovery(storage: storage);
      final dog = const DogRepository().getCurrentDog();
      await recovery.begin(dog);
      await HiveBoxes.deleteValue(HiveBoxes.dogsBoxName, dog.id);
      expect(await recovery.restore(), isFalse);
      expect(storage.deleted, ['/recovered.jpg']);
      storage.lost = '/unmatched.jpg';
      expect(await recovery.restore(), isFalse);
      expect(storage.deleted, contains('/unmatched.jpg'));
    },
  );
  test(
    'Staged result survives real Hive restart and is applied once',
    () async {
      await _withHive(() async {
        final storage = _LostPhoto();
        final recovery = PetPhotoRecovery(storage: storage);
        final dog = const DogRepository().getCurrentDog();
        final operation = await recovery.begin(dog);
        await recovery.stage(operation, '/staged.jpg');
        await Hive.close();
        await HiveBoxes.openAndSeedBoxes();
        expect(await recovery.restore(), isTrue);
        expect(const DogRepository().getCurrentDog().photoPath, '/staged.jpg');
        expect(await recovery.restore(), isFalse);
        expect(const DogRepository().getCurrentDog().photoPath, '/staged.jpg');
      });
    },
  );
  test('Picker cancellation clears the durable intent and a second pending pick cannot overwrite the first', () async {
    final storage = _LostPhoto();
    final recovery = PetPhotoRecovery(storage: storage);
    final dog = const DogRepository().getCurrentDog();
    final id = await recovery.begin(dog);
    await expectLater(recovery.begin(dog), throwsStateError);
    await recovery.complete(id);
    final pets = PetsController(imageStorageService: storage);
    addTearDown(pets.dispose);
    expect(await pets.pickAndUpdatePhoto(), isFalse);
    expect(
      HiveBoxes.getValue(
        HiveBoxes.settingsBoxName,
        PetPhotoRecovery.pendingKey,
      ),
      isNull,
    );
  });
  testWidgets(
    'Orphan cleanup preserves referenced, recent, and gallery originals',
    (tester) async {
      await tester.runAsync(() async {
        final directory = await Directory.systemTemp.createTemp(
          'pawcare_orphans_',
        );
        try {
          final pets = await Directory('${directory.path}/pawcare_pets')
              .create();
          final now = DateTime.now();
          final orphan = await File('${pets.path}/orphan.jpg')
              .writeAsString('old');
          final reference = await File('${pets.path}/booking.jpg')
              .writeAsString('history');
          final recent = await File('${pets.path}/recent.jpg')
              .writeAsString('new');
          final original = await File('${directory.path}/gallery.jpg')
              .writeAsString('original');
          await orphan.setLastModified(now.subtract(const Duration(days: 2)));
          await reference.setLastModified(
            now.subtract(const Duration(days: 2)),
          );
          await ImageStorageService(documentsDirectory: () async => directory)
              .pruneOrphanedPhotos({reference.path}, now: now);
          expect(await orphan.exists(), isFalse);
          expect(await reference.exists(), isTrue);
          expect(await recent.exists(), isTrue);
          expect(await original.exists(), isTrue);
        } finally {
          await directory.delete(recursive: true);
        }
      });
    },
  );
  test('Only old read notifications are archived, recipient scope and unread badge survive archive browsing', () async {
    await _withHive(() async {
      const repository = NotificationRepository();
      final now = DateTime.now();
      final old = now.subtract(const Duration(days: 120));
      await repository.addNotification(
        _notice('read_old', read: true, at: old),
      );
      await repository.addNotification(
        _notice('unread_old', read: false, at: old),
      );
      await repository.addNotification(
        _notice('read_new', read: true, at: now),
      );
      await repository.addNotification(
        _notice('foreign_old', read: true, at: old, owner: 'other'),
      );
      await HistoryMaintenance.archiveReadNotifications(
        active: Hive.box<dynamic>(HiveBoxes.notificationsBoxName),
        archive: Hive.lazyBox<dynamic>(HiveBoxes.archiveBoxName),
        now: now,
      );
      expect(
        repository.getAllNotifications().map((n) => n.id),
        containsAll(['unread_old', 'read_new']),
      );
      expect(
        repository.getAllNotifications().any((n) => n.id == 'read_old'),
        isFalse,
      );
      final page = await repository.readArchive();
      expect(page.items.single.id, 'read_old');
      final controller = NotificationsController();
      final before = controller.unreadCount;
      await controller.showArchived();
      expect(controller.unreadCount, before);
      expect(controller.value.single.id, 'read_old');
      controller.refresh();
      expect(controller.showingArchive, isFalse);
      controller.dispose();
      await Hive.close();
      await HiveBoxes.openAndSeedBoxes();
      expect((await repository.readArchive()).items.single.id, 'read_old');
    });
  });
  testWidgets(
    'A malformed active listing shows a recovery state on every provider screen',
    (tester) async {
      final router = AppRouter();
      await HiveBoxes.putValue(HiveBoxes.sittersBoxName, 'sitter_1', {
        'id': 'sitter_1',
        'rating': 'broken',
      });
      final provider = ProviderController(router: router);
      addTearDown(provider.dispose);
      addTearDown(router.dispose);
      expect(provider.value.hasListing, isFalse);
      for (final screen in [
        SitterDashboardScreen(
          controller: provider,
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
        SitterListingTab(
          controller: provider,
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
        SitterCalendarTab(
          controller: provider,
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
      ]) {
        await tester.pumpWidget(
          MaterialApp(theme: AppTheme.lightTheme, home: screen),
        );
        expect(find.text(AppStrings.missingListingTitle), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
      expect(const SitterRepository().getAllSitters(), hasLength(2));
    },
  );
  test('Recovery after an account switch preserves a photo already applied to the original account', () async {
    const dogs = DogRepository();
    const settings = SettingsRepository();
    final storage = _LostPhoto();
    final recovery = PetPhotoRecovery(storage: storage);
    final original = dogs.getCurrentDog();
    final operation = await recovery.begin(original);
    await recovery.stage(operation, '/already_applied.jpg');
    await dogs.saveDog(original.copyWith(photoPath: '/already_applied.jpg'));
    final originalEmail = settings.getUserEmail();
    await settings.activateOwner(email: 'other@example.com');
    expect(await recovery.restore(), isFalse);
    expect(storage.deleted, isEmpty);
    await settings.activateOwner(email: originalEmail);
    expect(dogs.getCurrentDog().photoPath, '/already_applied.jpg');
  });

  test(
    'Replacing a pet photo preserves files referenced by a listing gallery',
    () async {
      const dogs = DogRepository();
      const sitters = SitterRepository();
      await dogs.saveDog(
        dogs.getCurrentDog().copyWith(photoPath: '/gallery_shared.jpg'),
      );
      await sitters.saveSitter(
        sitters.getPrimarySitter().copyWith(
          galleryPaths: ['/gallery_shared.jpg'],
        ),
      );
      final storage = _LostPhoto();
      final pets = PetsController(imageStorageService: storage);
      addTearDown(pets.dispose);
      await pets.updatePhotoPath('/new.jpg');
      expect(storage.deleted, isEmpty);
      expect(sitters.isPhotoReferenced('/gallery_shared.jpg'), isTrue);
    },
  );
}
