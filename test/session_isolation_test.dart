import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/app/router/app_shell.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/theme/theme_controller.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/dog_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/auth/controller/auth_controller.dart';
import 'package:paw_care/features/bookings/view/owner_bookings_screen.dart';
import 'package:paw_care/features/discovery/controller/discovery_controller.dart';
import 'package:paw_care/features/discovery/view/explore_screen.dart';
import 'package:paw_care/features/home/view/owner_home_screen.dart';
import 'package:paw_care/features/provider/view/sitter_dashboard_screen.dart';

Future<BookingRequest> _submitBooking(DiscoveryController discovery) async {
  const dogs = DogRepository();
  final ownerId = const SettingsRepository().getOwnerId();
  if (dogs.getAllDogs().isEmpty) {
    await dogs.saveDog(
      HiveSeedData.initialDog.copyWith(id: 'pet_$ownerId', ownerId: ownerId),
    );
  }
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return discovery.submitBookingRequest(
    sitter: discovery.value.allSitters.first,
    dog: const DogRepository().getCurrentDog(),
    startDate: start,
    endDate: DateTime(start.year, start.month, start.day + 1),
    selectedUnits: 1,
    totalPrice: 500,
    careNotes: '',
  );
}

Future<DiscoveryController> _openDiscovery(
  WidgetTester tester,
  AppRouter router,
) async {
  router.setOwnerNavIndex(1);
  await tester.pump();
  return tester.widget<ExploreScreen>(find.byType(ExploreScreen)).controller;
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  testWidgets(
    'Owner signup and login isolate cached reservations without a role change',
    (tester) async {
      const settings = SettingsRepository();
      const sitters = SitterRepository();
      final sitter = sitters.getPrimarySitter();
      await sitters.saveSitter(sitter.copyWith(unavailableDates: <DateTime>[]));
      final router = AppRouter();
      final theme = ThemeController();
      final auth = AuthController(router: router);
      addTearDown(auth.dispose);
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: AppShell(router: router, themeController: theme),
        ),
      );

      await auth.signUp(
        name: 'Alpha Owner',
        email: 'alpha@example.com',
        password: 'password',
        confirmPassword: 'password',
        role: UserRole.owner,
      );
      await tester.pump();
      final ownerA = settings.getOwnerId();
      expect(
        tester
            .widget<OwnerHomeScreen>(find.byType(OwnerHomeScreen))
            .homeController
            .ownerFirstName,
        'Alpha',
      );
      final first = await _submitBooking(await _openDiscovery(tester, router));
      expect(first.ownerId, ownerA);

      await auth.signUp(
        name: 'Beta Owner',
        email: 'beta@example.com',
        password: 'password',
        confirmPassword: 'password',
        role: UserRole.owner,
      );
      await tester.pump();
      final ownerB = settings.getOwnerId();
      expect(ownerB, isNot(ownerA));
      expect(
        tester
            .widget<OwnerHomeScreen>(find.byType(OwnerHomeScreen))
            .homeController
            .ownerFirstName,
        'Beta',
      );
      router.setOwnerNavIndex(3);
      await tester.pump();
      final requestsB = tester
          .widget<OwnerBookingsScreen>(find.byType(OwnerBookingsScreen))
          .controller;
      expect(requestsB.value, isEmpty);
      await requestsB.cancelBooking(first);
      expect(
        BookingRepository()
            .getAllBookings()
            .firstWhere((booking) => booking.id == first.id)
            .status,
        BookingStatus.pending,
      );

      final second = await _submitBooking(await _openDiscovery(tester, router));
      expect(second.ownerId, ownerB);
      expect(second.ownerName, 'Beta');
      expect(second.id, isNot(first.id));

      await router.setRole(UserRole.sitter);
      await tester.pump();
      final provider = tester
          .widget<SitterDashboardScreen>(find.byType(SitterDashboardScreen))
          .controller;
      expect(
        provider.value.bookings.every(
          (booking) => booking.sitterId == settings.getActiveSitterId(),
        ),
        isTrue,
      );
      expect(
        provider.value.bookings.map((booking) => booking.id),
        containsAll(<String>[first.id, second.id]),
      );
      await provider.updateBookingStatus(first, BookingStatus.confirmed);
      await provider.updateBookingStatus(second, BookingStatus.confirmed);

      await auth.login(email: 'alpha@example.com', password: 'password');
      await tester.pump();
      expect(settings.getOwnerId(), ownerA);
      final homeA = tester.widget<OwnerHomeScreen>(
        find.byType(OwnerHomeScreen),
      );
      expect(homeA.homeController.ownerFirstName, 'Alpha');
      expect(homeA.homeController.activeConfirmedBooking?.id, first.id);
      router.setOwnerNavIndex(3);
      await tester.pump();
      expect(
        tester
            .widget<OwnerBookingsScreen>(find.byType(OwnerBookingsScreen))
            .controller
            .value
            .map((booking) => booking.id),
        <String>[first.id],
      );

      // Login from an already active owner session must also invalidate caches.
      await auth.login(email: 'beta@example.com', password: 'password');
      await tester.pump();
      expect(settings.getOwnerId(), ownerB);
      final homeB = tester.widget<OwnerHomeScreen>(
        find.byType(OwnerHomeScreen),
      );
      expect(homeB.homeController.ownerFirstName, 'Beta');
      expect(homeB.homeController.activeConfirmedBooking?.id, second.id);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('Sitter signup updates the persisted listing before routing', (
    tester,
  ) async {
    final router = AppRouter();
    final auth = AuthController(router: router);
    addTearDown(auth.dispose);
    addTearDown(router.dispose);
    const repository = SitterRepository();
    final untouched = repository.getAllSitters()[1];
    final succeeded = await auth.signUp(
      name: 'Updated Sitter',
      email: 'sitter@example.com',
      password: 'password',
      confirmPassword: 'password',
      role: UserRole.sitter,
    );
    expect(succeeded, isTrue);
    expect(repository.getPrimarySitter().name, 'Updated Sitter');
    expect(
      repository
          .getAllSitters()
          .firstWhere((sitter) => sitter.id == untouched.id)
          .name,
      untouched.name,
    );
  });
}
