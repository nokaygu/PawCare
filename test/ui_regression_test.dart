import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/widgets/paw_date_range_calendar.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/features/bookings/widgets/owner_booking_card.dart';
import 'package:paw_care/features/discovery/controller/discovery_controller.dart';
import 'package:paw_care/features/discovery/view/explore_screen.dart';
import 'package:paw_care/features/discovery/view/sitter_detail_screen.dart';
import 'package:paw_care/features/pets/controller/pets_controller.dart';
import 'package:paw_care/features/home/widgets/owner_home_sections.dart';
import 'package:paw_care/features/provider/controller/provider_controller.dart';
import 'package:paw_care/features/provider/widgets/sitter_dashboard_sections.dart';
import 'package:paw_care/features/provider/widgets/sitter_sub_tabs.dart';

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  testWidgets('Explore reset restores results and clears the search field', (
    tester,
  ) async {
    final controller = DiscoveryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _app(
        ExploreScreen(
          controller: controller,
          onSitterSelected: (_) {},
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'eşleşmeyen-arama');
    controller.setCategory(AppStrings.categoryWalking);
    controller.setMaxPrice(1);
    controller.setSortByPriceAsc(true);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.exploreEmptyTitle), findsOneWidget);
    final reset = find.text(AppStrings.clearFiltersButton);
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.exploreEmptyTitle), findsNothing);
    expect(controller.value.filteredSitters, isNotEmpty);
    expect(controller.value.searchQuery, isEmpty);
    expect(controller.value.selectedCategory, AppStrings.categoryAll);
    expect(controller.value.sortByPriceAsc, isFalse);
    expect(
      controller.value.maxPrice,
      (const DiscoveryFilterState(allSitters: [])).maxPrice,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('Provider lists every confirmed guest and shows an empty state', (
    tester,
  ) async {
    final first = _booking();
    final second = first.copyWith(id: 'booking_second', petName: 'Luna');
    await tester.pumpWidget(
      _app(
        _scrollable(
          ActiveGuestCardSection(
            confirmedBookings: <BookingRequest>[first, second],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(first.petName), findsOneWidget);
    expect(find.text(second.petName), findsOneWidget);
    expect(find.text(AppStrings.noActiveGuestsTitle), findsNothing);

    await tester.pumpWidget(_app(_scrollable(const ActiveGuestCardSection())));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noActiveGuestsTitle), findsOneWidget);
    expect(find.text(first.petName), findsNothing);
    expect(find.byIcon(Icons.chat_bubble_outline), findsNothing);
  });

  testWidgets('Owner booking card displays both years for a cross-year range', (
    tester,
  ) async {
    final booking = _booking().copyWith(
      startDate: DateTime(2026, 12, 31),
      endDate: DateTime(2027, 1, 2),
    );
    await tester.pumpWidget(
      _app(_scrollable(OwnerBookingCard(booking: booking))),
    );
    await tester.pumpAndSettle();

    expect(find.text('31 Aralık 2026 - 2 Ocak 2027'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
  });

  testWidgets('Booking details and actions fit a narrow phone card', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        _scrollable(
          Center(
            child: SizedBox(
              width: 320,
              child: OwnerBookingCard(
                booking: _booking().copyWith(status: BookingStatus.pending),
                onCancel: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.writeToSitterButton), findsOneWidget);
    expect(find.text(AppStrings.cancelRequestButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Home starts and disposes the pulse with the active reservation',
    (tester) async {
      var explored = false;
      Widget card(BookingRequest? booking) => _app(
        _scrollable(
          TodaysReservationLiveCard(
            activeBooking: booking,
            onExplore: () => explored = true,
          ),
        ),
      );
      await tester.pumpWidget(card(null));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.noActiveReservationTitle), findsOneWidget);
      expect(find.text(AppStrings.liveWalkingBadge), findsNothing);
      expect(find.text(AppStrings.defaultWalkerName), findsNothing);
      expect(find.text(AppStrings.liveTrackingButton), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
      await tester.tap(find.text(AppStrings.exploreSittersButton));
      expect(explored, isTrue);

      await tester.pumpWidget(card(_booking()));
      await tester.pump();
      expect(find.text(AppStrings.activeReservationBadge), findsOneWidget);
      expect(tester.binding.transientCallbackCount, greaterThan(0));

      await tester.pumpWidget(card(null));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.activeReservationBadge), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );

  testWidgets('Booking submit needs a complete selected date range', (
    tester,
  ) async {
    final discovery = DiscoveryController();
    final pets = PetsController();
    addTearDown(discovery.dispose);
    addTearDown(pets.dispose);
    final sitter = HiveSeedData.createInitialSitters().first.copyWith(
      unavailableDates: const <DateTime>[],
    );
    await tester.pumpWidget(
      _app(
        SitterDetailScreen(
          sitter: sitter,
          discoveryController: discovery,
          petsController: pets,
          onBack: () {},
          onBookingCompleted: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final submit = find.widgetWithText(
      ElevatedButton,
      AppStrings.sendBookingRequestButton,
    );
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);

    final day = find.descendant(
      of: find.byType(PawDateRangeCalendar),
      matching: find.text(DateTime.now().day.toString()),
    );
    await tester.ensureVisible(day);
    await tester.tap(day);
    await tester.pump();
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);

    await tester.tap(day);
    await tester.pump();
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Listing price and edit field reflect the service unit', (
    tester,
  ) async {
    final router = AppRouter();
    final controller = ProviderController(router: router);
    addTearDown(router.dispose);
    addTearDown(controller.dispose);
    final sitter = controller.value.primarySitter.copyWith(unitLabel: 'saat');
    controller.value = controller.value.copyWith(primarySitter: sitter);
    await tester.pumpWidget(
      _app(
        SitterListingTab(
          controller: controller,
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(AppStrings.unitPriceLabel(sitter.pricePerUnit, 'saat')),
      findsOneWidget,
    );
    await tester.tap(find.text(AppStrings.editListingAndPriceButton));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.fieldUnitPrice('saat')), findsOneWidget);
    expect(find.textContaining('Gecelik'), findsNothing);
  });
}

Widget _app(Widget home) => MaterialApp(theme: AppTheme.lightTheme, home: home);

Widget _scrollable(Widget child) =>
    Scaffold(body: SingleChildScrollView(child: child));

BookingRequest _booking() => HiveSeedData.createInitialBookings().first
    .copyWith(status: BookingStatus.confirmed);
