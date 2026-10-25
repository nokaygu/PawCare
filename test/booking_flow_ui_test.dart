import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/widgets/paw_date_range_calendar.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/features/discovery/controller/discovery_controller.dart';
import 'package:paw_care/features/discovery/view/sitter_detail_screen.dart';
import 'package:paw_care/features/pets/controller/pets_controller.dart';
import 'package:paw_care/features/provider/controller/provider_controller.dart';
import 'package:paw_care/features/provider/view/sitter_dashboard_screen.dart';

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  for (final type in [ServiceType.walk, ServiceType.dayCare]) {
    testWidgets(
      '${type.name} selects one date and enables the matching quote',
      (tester) async {
        final discovery = DiscoveryController();
        final pets = PetsController();
        final sitter = discovery.value.allSitters.firstWhere(
          (sitter) => sitter.serviceType == type,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: SitterDetailScreen(
              sitter: sitter,
              discoveryController: discovery,
              petsController: pets,
              onBack: () {},
              onBookingCompleted: () {},
            ),
          ),
        );
        final now = DateTime.now();
        final day = DateTime(now.year, now.month, now.day + 10);
        final calendar = tester.widget<PawDateRangeCalendar>(
          find.byType(PawDateRangeCalendar),
        );
        expect(calendar.singleDay, isTrue);
        calendar.onRangeChanged!(
          day,
          DateTime(day.year, day.month, day.day + 1),
        );
        await tester.pump();
        final submit = find.widgetWithText(
          ElevatedButton,
          AppStrings.sendBookingRequestButton,
        );
        expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
        if (type == ServiceType.walk) {
          final hours = tester.widget<DropdownButton<int>>(
            find.byType(DropdownButton<int>),
          );
          hours.onChanged!(2);
          await tester.pump();
          expect(find.text(AppStrings.currencyAmount(550)), findsOneWidget);
        } else {
          expect(find.byType(DropdownButton<int>), findsNothing);
          expect(find.text(AppStrings.currencyAmount(400)), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        discovery.dispose();
        pets.dispose();
      },
    );
  }

  testWidgets('A blocked hotel checkout is selectable without occupying it', (
    tester,
  ) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month + 1, 10);
    final checkout = DateTime(first.year, first.month, 11);
    DateTime? start;
    DateTime? end;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, update) => PawDateRangeCalendar(
              initialMonth: first,
              rangeStart: start,
              rangeEnd: end,
              unavailableDates: [checkout],
              exclusiveEnd: true,
              onRangeChanged: (a, b) => update(() {
                start = a;
                end = b;
              }),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('10'));
    await tester.pump();
    await tester.tap(find.text('11'));
    await tester.pump();
    expect(start, first);
    expect(end, checkout);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'A finished service can be completed from its own dashboard section',
    (tester) async {
      await const SettingsRepository().setUserRole(UserRole.sitter);
      final now = DateTime.now();
      final repository = BookingRepository();
      final booking = HiveSeedData.createInitialBookings().first.copyWith(
        id: 'finished_service',
        status: BookingStatus.confirmed,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.subtract(const Duration(days: 1)),
      );
      await repository.addBooking(booking);
      final router = AppRouter();
      final provider = ProviderController(
        router: router,
        bookingRepository: repository,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: SitterDashboardScreen(
            controller: provider,
            unreadNotifications: 0,
            onNotificationsTap: () {},
          ),
        ),
      );
      final complete = find.text(AppStrings.completeService);
      await tester.ensureVisible(complete);
      await tester.tap(complete);
      await tester.pumpAndSettle();
      expect(repository.getById(booking.id)!.status, BookingStatus.completed);
      expect(repository.getById(booking.id)!.completedAt, isNotNull);
      expect(find.text(AppStrings.awaitingCompletionTitle), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
      router.dispose();
    },
  );
}
