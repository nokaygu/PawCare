import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/theme/theme_controller.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/dog_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/auth/controller/auth_controller.dart';
import 'package:paw_care/features/notifications/controller/notifications_controller.dart';
import 'package:paw_care/features/onboarding/controller/onboarding_controller.dart';
import 'package:paw_care/features/pets/controller/pets_controller.dart';
import 'package:paw_care/features/pets/widgets/dog_editor_modal.dart';
import 'package:paw_care/features/profile/controller/profile_controller.dart';

class _SlowSettings extends SettingsRepository {
  final gate = Completer<void>();
  bool fail = false;
  @override
  Future<void> setIsDarkMode(bool value) async {
    await gate.future;
    if (fail) throw StateError('Disk');
    await super.setIsDarkMode(value);
  }

  @override
  Future<void> setUserRole(UserRole role) async {
    await gate.future;
    await super.setUserRole(role);
  }

  @override
  Future<void> updateOwnerProfile({
    required String ownerId,
    String? name,
    String? email,
  }) async {
    await gate.future;
    await super.updateOwnerProfile(ownerId: ownerId, name: name, email: email);
  }

  @override
  Future<String> activateOwner({required String email, String? name}) async {
    await gate.future;
    return super.activateOwner(email: email, name: name);
  }
}

class _FailedNotification extends NotificationsController {
  @override
  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? recipientId,
    UserRole? recipientRole,
    String? relatedRecordId,
  }) async => throw StateError('Secondary notification failed');
}

class _SlowDog extends DogRepository {
  final gate = Completer<void>();
  int saves = 0;
  @override
  Future<void> saveDog(Dog dog) async {
    saves++;
    await gate.future;
    throw StateError('Disk');
  }
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);
  test(
    'Closed theme and router controllers tolerate pending persistence',
    () async {
      final settings = _SlowSettings();
      final theme = ThemeController(settingsRepository: settings);
      final router = AppRouter(settingsRepository: settings);
      final themeTask = theme.setDarkMode(true);
      final routeTask = router.setRole(UserRole.sitter);
      theme.dispose();
      router.dispose();
      settings.gate.complete();
      await themeTask;
      await routeTask;
      expect(theme.value, ThemeMode.light);
      expect(router.role, UserRole.owner);
      expect(settings.getIsDarkMode(), isTrue);
    },
  );
  test(
    'Failed theme persistence keeps the selected theme and allows retry',
    () async {
      final settings = _SlowSettings()..fail = true;
      final theme = ThemeController(settingsRepository: settings);
      addTearDown(theme.dispose);
      final task = theme.setDarkMode(true);
      settings.gate.complete();
      await expectLater(task, throwsStateError);
      expect(theme.value, ThemeMode.light);
      expect(theme.isBusy, isFalse);
    },
  );
  test(
    'Closed profile persists its captured account without stale callback',
    () async {
      final settings = _SlowSettings();
      final router = AppRouter();
      final theme = ThemeController();
      var callbacks = 0;
      final profile = ProfileController(
        router: router,
        themeController: theme,
        settingsRepository: settings,
        onProfileChanged: () => callbacks++,
      );
      final task = profile.updateActiveUserProfile(
        name: 'Kalıcı',
        email: 'saved@example.com',
      );
      await Future<void>.delayed(Duration.zero);
      profile.dispose();
      settings.gate.complete();
      await task;
      expect(settings.getOwnerName(), 'Kalıcı');
      expect(callbacks, 0);
      router.dispose();
      theme.dispose();
    },
  );
  test(
    'Account switch during a profile await cannot write the new account',
    () async {
      final settings = _SlowSettings();
      final router = AppRouter();
      final theme = ThemeController();
      final profile = ProfileController(
        router: router,
        themeController: theme,
        settingsRepository: settings,
      );
      addTearDown(profile.dispose);
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      final task = profile.updateActiveUserProfile(
        name: 'Wrong',
        email: 'wrong@example.com',
      );
      await Future<void>.delayed(Duration.zero);
      await const SettingsRepository().activateOwner(
        email: 'other@example.com',
        name: 'Other',
      );
      settings.gate.complete();
      await expectLater(task, throwsStateError);
      expect(settings.getOwnerName(), 'Other');
      expect(settings.getUserEmail(), 'other@example.com');
    },
  );
  test(
    'Sitter email collision is rejected before the listing name changes',
    () async {
      final router = AppRouter();
      final theme = ThemeController();
      await router.setRole(UserRole.sitter);
      final profile = ProfileController(router: router, themeController: theme);
      addTearDown(profile.dispose);
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      final before = const SitterRepository().getPrimarySitter().name;
      await expectLater(
        profile.updateActiveUserProfile(
          name: 'Wrong',
          email: AppStrings.defaultOwnerEmail,
        ),
        throwsArgumentError,
      );
      expect(const SitterRepository().getPrimarySitter().name, before);
    },
  );
  test('Two auth controllers serialize identity writes; disposed queued auth does not activate', () async {
    final settings = _SlowSettings();
    final router = AppRouter();
    final first = AuthController(router: router, settingsRepository: settings);
    final second = AuthController(router: router);
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    addTearDown(router.dispose);
    final a = first.login(email: 'first@example.com', password: 'password');
    final b = second.login(email: 'second@example.com', password: 'password');
    second.dispose();
    settings.gate.complete();
    expect(await a, isTrue);
    expect(await b, isFalse);
    expect(settings.getUserEmail(), 'first@example.com');
    expect(settings.findOwnerIdByEmail('second@example.com'), isNull);
  });
  test(
    'Onboarding disposed during role write never changes navigation afterwards',
    () async {
      final settings = _SlowSettings();
      final router = AppRouter(settingsRepository: settings);
      router.setSitterNavIndex(2);
      final onboarding = OnboardingController(router: router);
      final task = onboarding.selectRoleAndContinue(UserRole.sitter);
      onboarding.dispose();
      settings.gate.complete();
      await task;
      expect(router.sitterNavIndex, 2);
      router.dispose();
    },
  );
  test(
    'A secondary notification failure keeps a successful pet save successful',
    () async {
      final notifications = _FailedNotification();
      final pets = PetsController(notificationsController: notifications);
      addTearDown(pets.dispose);
      addTearDown(notifications.dispose);
      await pets.updateDog(pets.currentDog.copyWith(name: 'Saved'));
      expect(const DogRepository().getCurrentDog().name, 'Saved');
      expect(pets.lastWarning, AppStrings.notificationDeliveryFailed);
    },
  );
  testWidgets(
    'Pending pet save disables duplicate submit and failed save keeps the form open',
    (tester) async {
      final repository = _SlowDog();
      final pets = PetsController(dogRepository: repository);
      addTearDown(pets.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: DogEditorModal(controller: pets, initialDog: pets.currentDog),
          ),
        ),
      );
      await tester.ensureVisible(find.text(AppStrings.save));
      await tester.tap(find.text(AppStrings.save));
      await tester.pump();
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(repository.saves, 1);
      repository.gate.complete();
      await tester.pumpAndSettle();
      expect(find.byType(DogEditorModal), findsOneWidget);
      expect(find.text(AppStrings.bookingSaveFailed), findsOneWidget);
      expect(pets.isBusy, isFalse);
    },
  );
}
