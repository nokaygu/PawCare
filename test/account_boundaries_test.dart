import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/app/router/app_shell.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/theme/theme_controller.dart';
import 'package:paw_care/core/utils/image_storage_service.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/dog_repository.dart';
import 'package:paw_care/data/repositories/notification_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/auth/controller/auth_controller.dart';
import 'package:paw_care/features/notifications/controller/notifications_controller.dart';
import 'package:paw_care/features/pets/controller/pets_controller.dart';
import 'package:paw_care/features/provider/controller/provider_controller.dart';

class _PendingPhoto extends ImageStorageService {
  final pending = Completer<String?>();
  final removed = <String>[];
  @override
  Future<String?> pickAndSavePetPhoto() => pending.future;
  @override
  Future<void> deletePetPhoto(String path) async => removed.add(path);
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  test(
    'Owners have separate pets, active selection and write access',
    () async {
      const settings = SettingsRepository();
      const dogs = DogRepository();
      final initial = dogs.getCurrentDog();
      final a = await settings.activateOwner(email: 'a@example.com');
      expect(dogs.getAllDogs(), isEmpty);
      final first = initial.copyWith(id: 'a_pet', ownerId: a);
      await dogs.saveDog(first);
      await dogs.setActiveDog(first.id);
      final b = await settings.activateOwner(email: 'b@example.com');
      expect(dogs.findCurrentDog(), isNull);
      expect(settings.getActiveDogId(), isEmpty);
      await expectLater(dogs.setActiveDog(first.id), throwsStateError);
      await expectLater(dogs.saveDog(first), throwsStateError);
      await expectLater(
        dogs.saveDog(first.copyWith(ownerId: b)),
        throwsStateError,
      );
      final second = initial.copyWith(id: 'b_pet', ownerId: b);
      await dogs.saveDog(second);
      await dogs.setActiveDog(second.id);
      await settings.activateOwner(email: 'a@example.com');
      expect(dogs.getCurrentDog().id, first.id);
      expect(dogs.getAllDogs().map((dog) => dog.id), [first.id]);
      await settings.activateOwner(email: 'b@example.com');
      expect(dogs.getCurrentDog().id, second.id);
    },
  );

  test('Invalid pet and vaccine IDs never modify the selected pet', () async {
    const dogs = DogRepository();
    final before = dogs.getCurrentDog();
    await expectLater(
      dogs.addVaccination('missing', before.vaccinations.first),
      throwsStateError,
    );
    await expectLater(
      dogs.toggleVaccinationStatus(before.id, 'missing'),
      throwsStateError,
    );
    expect(dogs.getCurrentDog().toMap(), before.toMap());
  });

  testWidgets(
    'New owner sees empty states and returning owner gets their pet',
    (tester) async {
      final router = AppRouter();
      final theme = ThemeController();
      final auth = AuthController(router: router);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AppShell(router: router, themeController: theme),
        ),
      );
      await auth.login(email: 'empty@example.com', password: 'password');
      await tester.pump();
      expect(find.text(AppStrings.noPetsTitle), findsOneWidget);
      expect(find.text('Barley'), findsNothing);
      router.setOwnerNavIndex(2);
      await tester.pump();
      expect(find.text(AppStrings.addFirstPet), findsOneWidget);
      await auth.login(
        email: AppStrings.defaultOwnerEmail,
        password: 'password',
      );
      await tester.pump();
      expect(find.text('Barley'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
      theme.dispose();
      router.dispose();
    },
  );

  test(
    'Sitter accounts keep distinct listings and restore the correct role',
    () async {
      final router = AppRouter();
      final auth = AuthController(router: router);
      addTearDown(auth.dispose);
      addTearDown(router.dispose);
      const settings = SettingsRepository();
      const sitters = SitterRepository();
      final original = sitters.getPrimarySitter();
      await auth.signUp(
        name: 'Alpha',
        email: 'alpha@sitter.test',
        password: 'password',
        confirmPassword: 'password',
        role: UserRole.sitter,
      );
      final a = settings.getActiveSitterId();
      expect(a, isNot(original.id));
      expect(sitters.getPrimarySitter().isPublished, isFalse);
      await auth.signUp(
        name: 'Beta',
        email: 'beta@sitter.test',
        password: 'password',
        confirmPassword: 'password',
        role: UserRole.sitter,
      );
      expect(settings.getActiveSitterId(), isNot(a));
      await auth.login(email: 'alpha@sitter.test', password: 'password');
      expect(router.role, UserRole.sitter);
      expect(settings.getActiveSitterId(), a);
      expect(settings.getSitterName(), 'Alpha');
      expect(sitters.getById(original.id)!.name, original.name);
      expect(sitters.getPrimarySitter().name, 'Alpha');
      final provider = ProviderController(router: router);
      await provider.updateListingDetails(
        facilityTitle: 'Alpha hotel',
        location: 'Kadıköy',
        pricePerUnit: 500,
        bio: '',
      );
      expect(sitters.getAllSitters().any((listing) => listing.id == a), isTrue);
      provider.dispose();
      await settings.setSitterEmail('renamed@sitter.test');
      await auth.login(email: 'beta@sitter.test', password: 'password');
      await auth.login(email: 'renamed@sitter.test', password: 'password');
      expect(settings.getActiveSitterId(), a);
    },
  );

  test(
    'One email cannot silently select a different role after signup',
    () async {
      final router = AppRouter();
      final auth = AuthController(router: router);
      addTearDown(auth.dispose);
      addTearDown(router.dispose);
      expect(
        await auth.signUp(
          name: 'Other',
          email: AppStrings.defaultOwnerEmail,
          password: 'password',
          confirmPassword: 'password',
          role: UserRole.sitter,
        ),
        isFalse,
      );
    },
  );

  test(
    'Notifications and read states belong to one recipient and role',
    () async {
      const settings = SettingsRepository();
      const repository = NotificationRepository();
      final notifications = NotificationsController();
      addTearDown(notifications.dispose);
      final a = await settings.activateOwner(email: 'a@example.com');
      await notifications.addNotification(
        title: 'Only A',
        message: 'Private',
        type: NotificationType.bookingCreated,
      );
      final id = repository.getAllNotifications().single.id;
      await settings.activateOwner(email: 'b@example.com');
      expect(repository.getAllNotifications(), isEmpty);
      await repository.markAsRead(id);
      await repository.markAllAsRead();
      await settings.activateOwner(email: 'a@example.com');
      expect(repository.getAllNotifications().single.isRead, isFalse);
      await repository.markAllAsRead();
      expect(repository.getAllNotifications().single.isRead, isTrue);
      await notifications.addNotification(
        title: 'To sitter',
        message: 'Request',
        type: NotificationType.bookingCreated,
        recipientId: 'sitter_1',
        recipientRole: UserRole.sitter,
        relatedRecordId: 'booking_a',
      );
      expect(
        repository.getAllNotifications().every((n) => n.recipientId == a),
        isTrue,
      );
      await settings.setUserRole(UserRole.sitter);
      final request = repository.getAllNotifications().single;
      expect(request.title, 'To sitter');
      expect(request.relatedRecordId, 'booking_a');
      expect(request.createdAt, isNotNull);
      await settings.setActiveSitterId('sitter_2');
      expect(repository.getAllNotifications(), isEmpty);
    },
  );

  test('Notification labels use the required persisted event time', () {
    final created = DateTime(2026, 10, 25, 12);
    expect(AppStrings.notificationTime(created, created), AppStrings.timeNow);
    expect(
      AppStrings.notificationTime(
        created,
        created.add(const Duration(minutes: 12)),
      ),
      '12 dk önce',
    );
    expect(
      AppStrings.notificationTime(
        created,
        created.add(const Duration(hours: 2)),
      ),
      '2 saat önce',
    );
    expect(
      AppStrings.notificationTime(
        created,
        created.add(const Duration(days: 2)),
      ),
      AppStrings.formatShortDate(created),
    );
  });

  test(
    'Photo results for a disposed controller are discarded safely',
    () async {
      final storage = _PendingPhoto();
      final pets = PetsController(imageStorageService: storage);
      final task = pets.pickAndUpdatePhoto();
      pets.dispose();
      storage.pending.complete('/new.jpg');
      expect(await task, isFalse);
      expect(storage.removed, ['/new.jpg']);
    },
  );

  test(
    'Photo results cannot move to a different owner after account switch',
    () async {
      final storage = _PendingPhoto();
      final pets = PetsController(imageStorageService: storage);
      final task = pets.pickAndUpdatePhoto();
      await const SettingsRepository().activateOwner(email: 'new@example.com');
      pets.refresh();
      storage.pending.complete('/new.jpg');
      expect(await task, isFalse);
      expect(pets.hasDog, isFalse);
      expect(storage.removed, ['/new.jpg']);
      pets.dispose();
    },
  );

  test('Intentional empty boxes, owner selection and sitter sessions survive restart', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pawcare_accounts_',
    );
    try {
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      const settings = SettingsRepository();
      const dogs = DogRepository();
      final a = await settings.activateOwner(email: 'a@example.com');
      final pet = HiveSeedData.initialDog.copyWith(id: 'a_pet', ownerId: a);
      await dogs.saveDog(pet);
      await dogs.setActiveDog(pet.id);
      await Hive.box<dynamic>(HiveBoxes.bookingsBoxName).clear();
      await Hive.box<dynamic>(HiveBoxes.notificationsBoxName).clear();
      final router = AppRouter();
      final auth = AuthController(router: router);
      await auth.signUp(
        name: 'New sitter',
        email: 'new@sitter.test',
        password: 'password',
        confirmPassword: 'password',
        role: UserRole.sitter,
      );
      final sitterId = settings.getActiveSitterId();
      auth.dispose();
      router.dispose();
      await Hive.close();
      await HiveBoxes.openAndSeedBoxes();
      expect(Hive.box<dynamic>(HiveBoxes.bookingsBoxName).isEmpty, isTrue);
      expect(Hive.box<dynamic>(HiveBoxes.notificationsBoxName).isEmpty, isTrue);
      expect(settings.getActiveSitterId(), sitterId);
      expect(settings.getSitterName(), 'New sitter');
      expect(dogs.getCurrentDog().id, pet.id);
      await settings.activateOwner(email: 'b@example.com');
      expect(dogs.findCurrentDog(), isNull);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
