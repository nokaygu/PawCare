import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/app/router/app_shell.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/theme/theme_controller.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/profile/controller/profile_controller.dart';
import 'package:paw_care/features/profile/view/profile_screen.dart';
import 'package:paw_care/features/profile/widgets/profile_modals.dart';

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  testWidgets(
    'Profile rename updates existing Home, Explore and provider names',
    (tester) async {
      const repository = SitterRepository();
      final original = repository.getPrimarySitter();
      final other = repository.getAllSitters().firstWhere(
        (sitter) => sitter.id != original.id,
      );
      final snapshots = const BookingRepository().getAllBookings();
      final router = AppRouter();
      final theme = ThemeController();
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AppShell(router: router, themeController: theme),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(AppStrings.nameAndLocation(original.name, original.location)),
        findsOneWidget,
      );
      router.setOwnerNavIndex(1);
      await tester.pumpAndSettle();
      expect(
        find.text(
          AppStrings.sitterNameLocationDistance(
            original.name,
            original.location,
            original.distanceKm,
          ),
        ),
        findsOneWidget,
      );

      await router.setRole(UserRole.sitter);
      router.setSitterNavIndex(4);
      await tester.pumpAndSettle();
      final profile = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
      await profile.controller.updateActiveUserProfile(
        name: 'Ece Kaya',
        email: 'ece@example.com',
      );
      router.setSitterNavIndex(0);
      await tester.pumpAndSettle();
      expect(find.text('Ece Kaya'), findsOneWidget);

      await router.setRole(UserRole.owner);
      router.setOwnerNavIndex(0);
      await tester.pumpAndSettle();
      expect(
        find.text(AppStrings.nameAndLocation('Ece Kaya', original.location)),
        findsOneWidget,
      );
      expect(
        find.text(AppStrings.nameAndLocation(original.name, original.location)),
        findsNothing,
      );
      expect(
        find.text(AppStrings.nameAndLocation(other.name, other.location)),
        findsOneWidget,
      );
      router.setOwnerNavIndex(1);
      await tester.pumpAndSettle();
      expect(
        find.text(
          AppStrings.sitterNameLocationDistance(
            'Ece Kaya',
            original.location,
            original.distanceKm,
          ),
        ),
        findsOneWidget,
      );
      expect(
        repository
            .getAllSitters()
            .firstWhere((sitter) => sitter.id == other.id)
            .name,
        other.name,
      );
      expect(
        const BookingRepository().getAllBookings().map(
          (booking) => booking.sitterName,
        ),
        snapshots.map((booking) => booking.sitterName),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'Empty name and owner profile edits preserve sitter listing names',
    () async {
      const repository = SitterRepository();
      const settings = SettingsRepository();
      final originalNames = repository
          .getAllSitters()
          .map((sitter) => sitter.name)
          .toList();
      await settings.setUserRole(UserRole.sitter);
      final router = AppRouter();
      final theme = ThemeController();
      final profile = ProfileController(router: router, themeController: theme);
      addTearDown(profile.dispose);
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      final previousProfileName = settings.getSitterName();
      await profile.updateActiveUserProfile(
        name: '   ',
        email: 'new@example.com',
      );
      expect(settings.getSitterName(), previousProfileName);
      expect(
        repository.getAllSitters().map((sitter) => sitter.name),
        originalNames,
      );

      await router.setRole(UserRole.owner);
      await profile.updateActiveUserProfile(
        name: 'Yeni Sahip',
        email: 'owner@example.com',
      );
      expect(settings.getOwnerName(), 'Yeni Sahip');
      expect(
        repository.getAllSitters().map((sitter) => sitter.name),
        originalNames,
      );
    },
  );

  test(
    'Owner email collision rejects the edit before changing the name',
    () async {
      const settings = SettingsRepository();
      final firstId = await settings.activateOwner(
        email: 'first@example.com',
        name: 'İlk Sahip',
      );
      await settings.activateOwner(
        email: 'second@example.com',
        name: 'İkinci Sahip',
      );
      await settings.activateOwner(email: 'first@example.com');
      final router = AppRouter();
      final theme = ThemeController();
      var notifications = 0;
      final profile = ProfileController(
        router: router,
        themeController: theme,
        onProfileChanged: () => notifications++,
      );
      addTearDown(profile.dispose);
      addTearDown(router.dispose);
      addTearDown(theme.dispose);

      await expectLater(
        profile.updateActiveUserProfile(
          name: 'Yanlış Ad',
          email: 'second@example.com',
        ),
        throwsArgumentError,
      );
      expect(settings.getOwnerId(), firstId);
      expect(settings.getOwnerName(), 'İlk Sahip');
      expect(settings.getUserEmail(), 'first@example.com');
      expect(notifications, 0);
    },
  );

  testWidgets(
    'Conflicting owner email leaves the profile unchanged and dialog open',
    (tester) async {
      const settings = _ConflictingEmailSettings();
      final originalName = settings.getOwnerName();
      final router = AppRouter(settingsRepository: settings);
      final theme = ThemeController();
      var notifications = 0;
      final profile = ProfileController(
        router: router,
        themeController: theme,
        settingsRepository: settings,
        onProfileChanged: () => notifications++,
      );
      addTearDown(profile.dispose);
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    EditUserProfileModal.show(context, controller: profile),
                child: const Text(AppStrings.editAccountModalTitle),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text(AppStrings.editAccountModalTitle));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).at(0),
        'Kaydedilmemesi Gereken Ad',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'another-owner@example.com',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.save));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.profileEmailInUse), findsOneWidget);
      expect(find.byType(EditUserProfileModal), findsOneWidget);
      expect(settings.getOwnerName(), originalName);
      expect(notifications, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'Sitter rename persists across closing and reopening the Hive database',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'pawcare_profile_sync_',
      );
      try {
        Hive.init(directory.path);
        await HiveBoxes.openAndSeedBoxes();
        const settings = SettingsRepository();
        const repository = SitterRepository();
        await settings.setUserRole(UserRole.sitter);
        final originalOrder = repository.getAllSitters();
        await settings.setActiveSitterId(originalOrder[1].id);
        await Hive.box<dynamic>(HiveBoxes.sittersBoxName).clear();
        for (final sitter in originalOrder.reversed) {
          await repository.saveSitter(sitter);
        }
        final target = repository.getPrimarySitter();
        expect(target.id, settings.getActiveSitterId());
        expect(target.id, isNot(repository.getAllSitters().first.id));
        final originalNames = <String, String>{
          for (final sitter in repository.getAllSitters())
            sitter.id: sitter.name,
        };
        final router = AppRouter();
        final theme = ThemeController();
        final profile = ProfileController(
          router: router,
          themeController: theme,
        );
        try {
          await profile.updateActiveUserProfile(
            name: 'Kalıcı Bakıcı',
            email: 'persisted@example.com',
          );
        } finally {
          profile.dispose();
          router.dispose();
          theme.dispose();
        }
        await Hive.close();
        Hive.init(directory.path);
        await HiveBoxes.openAndSeedBoxes();

        expect(settings.getSitterName(), 'Kalıcı Bakıcı');
        expect(repository.getPrimarySitter().id, target.id);
        for (final sitter in repository.getAllSitters()) {
          expect(
            sitter.name,
            sitter.id == target.id ? 'Kalıcı Bakıcı' : originalNames[sitter.id],
          );
        }
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
}

class _ConflictingEmailSettings extends SettingsRepository {
  const _ConflictingEmailSettings();

  @override
  Future<void> setUserEmail(String email) async {
    throw ArgumentError(email);
  }
}
