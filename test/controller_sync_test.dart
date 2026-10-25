import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/app/router/app_shell.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/theme/theme_controller.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/discovery/controller/discovery_controller.dart';
import 'package:paw_care/features/bookings/view/owner_bookings_screen.dart';
import 'package:paw_care/features/auth/controller/auth_controller.dart';
import 'package:paw_care/features/home/controller/home_controller.dart';
import 'package:paw_care/features/home/view/owner_home_screen.dart';
import 'package:paw_care/features/profile/view/profile_screen.dart';
import 'package:paw_care/features/provider/view/sitter_dashboard_screen.dart';
import 'package:paw_care/features/provider/controller/provider_controller.dart';

class _CountingBookings extends BookingRepository {
  List<BookingRequest> entries;
  int reads = 0;

  _CountingBookings(this.entries);

  @override
  List<BookingRequest> getAllBookings() {
    reads++;
    return entries;
  }
}

BookingRequest _todayBooking() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return HiveSeedData.createInitialBookings().first.copyWith(
    id: 'book_999',
    startDate: today,
    endDate: today.add(const Duration(days: 1)),
    status: BookingStatus.confirmed,
  );
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  test('Home getters use cached bookings and refresh current dates', () {
    final booking = _todayBooking();
    final repository = _CountingBookings(<BookingRequest>[booking]);
    final router = AppRouter();
    final home = HomeController(router: router, bookingRepository: repository);
    addTearDown(home.dispose);
    addTearDown(router.dispose);

    for (var index = 0; index < 5; index++) {
      expect(home.activeConfirmedBooking?.id, booking.id);
      expect(home.ownerFirstName, AppStrings.defaultOwnerFallbackName);
    }
    expect(repository.reads, 1);

    repository.entries = <BookingRequest>[
      booking.copyWith(
        startDate: booking.startDate.subtract(const Duration(days: 4)),
        endDate: booking.startDate.subtract(const Duration(days: 2)),
      ),
      booking.copyWith(
        id: 'future',
        startDate: booking.startDate.add(const Duration(days: 2)),
        endDate: booking.startDate.add(const Duration(days: 3)),
      ),
      booking.copyWith(id: 'pending', status: BookingStatus.pending),
    ];
    home.refreshSitters();
    expect(home.activeConfirmedBooking, isNull);
    expect(repository.reads, 2);
  });

  testWidgets('Cancellation refreshes home and provider through AppShell', (
    tester,
  ) async {
    final booking = _todayBooking().copyWith(status: BookingStatus.pending);
    await BookingRepository().addBooking(booking);
    final router = AppRouter();
    final theme = ThemeController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AppShell(router: router, themeController: theme),
      ),
    );
    final home = tester.widget<OwnerHomeScreen>(find.byType(OwnerHomeScreen));
    expect(home.homeController.activeConfirmedBooking, isNull);

    router.setOwnerNavIndex(3);
    await tester.pump();
    final requests = tester.widget<OwnerBookingsScreen>(
      find.byType(OwnerBookingsScreen),
    );
    await requests.controller.cancelBooking(booking);
    expect(home.homeController.activeConfirmedBooking, isNull);
    expect(
      requests.controller.value.firstWhere((b) => b.id == booking.id).status,
      BookingStatus.cancelled,
    );

    await router.setRole(UserRole.sitter);
    await tester.pump();
    final provider = tester.widget<SitterDashboardScreen>(
      find.byType(SitterDashboardScreen),
    );
    expect(
      provider.controller.value.confirmedBookings.any(
        (b) => b.id == booking.id,
      ),
      isFalse,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    theme.dispose();
  });

  testWidgets('Profile edits refresh cached names in both roles', (
    tester,
  ) async {
    final router = AppRouter();
    final theme = ThemeController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AppShell(router: router, themeController: theme),
      ),
    );
    router.setOwnerNavIndex(4);
    await tester.pump();
    final profile = tester.widget<ProfileScreen>(find.byType(ProfileScreen));
    await profile.controller.updateActiveUserProfile(
      name: 'Deniz Kaya',
      email: 'deniz@example.com',
    );
    router.setOwnerNavIndex(0);
    await tester.pump();
    final home = tester.widget<OwnerHomeScreen>(find.byType(OwnerHomeScreen));
    expect(home.homeController.ownerFirstName, 'Deniz');

    await router.setRole(UserRole.sitter);
    router.setSitterNavIndex(4);
    await tester.pump();
    final sitterProfile = tester.widget<ProfileScreen>(
      find.byType(ProfileScreen),
    );
    await sitterProfile.controller.updateActiveUserProfile(
      name: 'Ece Kaya',
      email: 'ece@example.com',
    );
    router.setSitterNavIndex(0);
    await tester.pump();
    final provider = tester.widget<SitterDashboardScreen>(
      find.byType(SitterDashboardScreen),
    );
    expect(provider.controller.value.sitterDisplayName, 'Ece Kaya');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    theme.dispose();
  });

  test('Date range text preserves both years across a year boundary', () {
    expect(
      AppStrings.formatDateRange(DateTime(2026, 12, 31), DateTime(2027, 1, 2)),
      '31 Aralık 2026 - 2 Ocak 2027',
    );
  });

  test(
    'Provider monthly earnings contain only this month confirmed bookings',
    () {
      final current = _todayBooking();
      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1, 1);
      final state = ProviderState(
        sitterDisplayName: AppStrings.defaultSitterFullName,
        primarySitter: HiveSeedData.createInitialSitters().first,
        bookings: <BookingRequest>[
          current,
          current.copyWith(
            id: 'old',
            startDate: previousMonth,
            endDate: previousMonth,
            totalPrice: 99000,
          ),
          current.copyWith(id: 'pending', status: BookingStatus.pending),
        ],
      );
      expect(state.totalConfirmedEarnings, current.totalPrice);
      expect(
        state.copyWith(bookings: <BookingRequest>[]).totalConfirmedEarnings,
        0,
      );
    },
  );

  testWidgets('Signup refreshes cached owner and sitter identities', (
    tester,
  ) async {
    final router = AppRouter();
    final theme = ThemeController();
    final auth = AuthController(router: router);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: AppShell(router: router, themeController: theme),
      ),
    );
    router.showWelcome();
    await tester.pump();
    expect(
      await auth.signUp(
        name: 'Deniz Kaya',
        email: 'deniz@example.com',
        password: 'secret123',
        confirmPassword: 'secret123',
        role: UserRole.owner,
      ),
      isTrue,
    );
    await tester.pump();
    final home = tester.widget<OwnerHomeScreen>(find.byType(OwnerHomeScreen));
    expect(home.homeController.ownerFirstName, 'Deniz');

    router.showWelcome();
    await tester.pump();
    expect(
      await auth.signUp(
        name: 'Ece Kaya',
        email: 'ece@example.com',
        password: 'secret123',
        confirmPassword: 'secret123',
        role: UserRole.sitter,
      ),
      isTrue,
    );
    await tester.pump();
    final provider = tester.widget<SitterDashboardScreen>(
      find.byType(SitterDashboardScreen),
    );
    expect(provider.controller.value.sitterDisplayName, 'Ece Kaya');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
    router.dispose();
    theme.dispose();
  });

  test(
    'Booking submission rechecks saved availability before writing',
    () async {
      final controller = DiscoveryController();
      addTearDown(controller.dispose);
      final sitter = controller.value.allSitters.first;
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day + 10);
      final end = DateTime(start.year, start.month, start.day + 2);
      await const SitterRepository().saveSitter(
        sitter.copyWith(unavailableDates: <DateTime>[start]),
      );
      final bookingsBefore = BookingRepository().getAllBookings().length;
      await expectLater(
        controller.submitBookingRequest(
          sitter: sitter,
          dog: HiveSeedData.initialDog,
          startDate: start,
          endDate: end,
          selectedUnits: 2,
          totalPrice: 950,
          careNotes: '',
        ),
        throwsArgumentError,
      );
      expect(BookingRepository().getAllBookings().length, bookingsBefore);
    },
  );
}
