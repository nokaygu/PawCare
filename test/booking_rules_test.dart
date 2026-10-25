import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/utils/record_id.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/models/booking_policy.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/discovery/controller/discovery_controller.dart';
import 'package:paw_care/features/provider/controller/provider_controller.dart';
import 'package:paw_care/features/provider/view/sitter_dashboard_screen.dart';
import 'package:paw_care/features/provider/widgets/sitter_dashboard_sections.dart';
import 'package:paw_care/features/provider/widgets/sitter_sub_tabs.dart';

DateTime _futureDay() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 10);
}

BookingRequest _request(
  String id,
  SitterListing sitter,
  DateTime start,
  DateTime end,
) => HiveSeedData.createInitialBookings().first.copyWith(
  id: id,
  sitterId: sitter.id,
  sitterName: sitter.name,
  serviceType: sitter.serviceType,
  petId: HiveSeedData.initialDog.id,
  startDate: start,
  endDate: end,
  status: BookingStatus.pending,
);

class _SlowCreation extends BookingRepository {
  final gate = Completer<void>();
  @override
  Future<void> addBooking(BookingRequest booking) async {
    await gate.future;
    await super.addBooking(booking);
  }
}

class _FailedDecision extends BookingRepository {
  final gate = Completer<void>();
  @override
  Future<BookingRequest> updateBookingStatus(
    String id,
    BookingStatus status,
  ) async {
    await gate.future;
    throw StateError('Disk unavailable');
  }
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  for (final type in ServiceType.values) {
    test('${type.name} prices its own duration in integer cents', () {
      final sitter = HiveSeedData.createInitialSitters().first.copyWith(
        serviceType: type,
        pricePerUnit: 450.90,
      );
      final start = _futureDay();
      final end = start.add(
        type == ServiceType.walk
            ? const Duration(hours: 2)
            : const Duration(days: 2),
      );
      final quote = BookingPolicy.quote(sitter, start, end);
      expect(quote.units, 2);
      expect(quote.subtotalCents, 90180);
      expect(quote.totalCents, 95180);
    });
  }

  test(
    'Invalid same-day, reversed, partial-hour and oversized ranges fail',
    () {
      final start = _futureDay();
      final hotel = HiveSeedData.createInitialSitters().first;
      final walk = HiveSeedData.createInitialSitters()[1];
      expect(
        () => BookingPolicy.quote(hotel, start, start),
        throwsArgumentError,
      );
      expect(
        () => BookingPolicy.quote(
          walk,
          start.add(const Duration(hours: 18)),
          start.add(const Duration(hours: 9)),
        ),
        throwsArgumentError,
      );
      expect(
        () => BookingPolicy.quote(
          walk,
          start,
          start.add(const Duration(minutes: 90)),
        ),
        throwsArgumentError,
      );
      expect(
        () => BookingPolicy.quote(
          walk,
          start,
          start.add(const Duration(days: 1)),
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'Checkout releases a hotel day while a blocked occupied day rejects it',
    () {
      final start = _futureDay();
      final end = DateTime(start.year, start.month, start.day + 2);
      final sitter = HiveSeedData.createInitialSitters().first.copyWith(
        unavailableDates: [end],
      );
      expect(
        BookingPolicy.available(
          sitter: sitter,
          start: start,
          end: end,
          now: start.subtract(const Duration(days: 1)),
        ),
        isTrue,
      );
      expect(
        BookingPolicy.available(
          sitter: sitter.copyWith(unavailableDates: [start]),
          start: start,
          end: end,
          now: start.subtract(const Duration(days: 1)),
        ),
        isFalse,
      );
    },
  );

  test(
    'Capacity counts simultaneous occupants instead of all overlapping rows',
    () {
      final start = _futureDay();
      final end = start.add(const Duration(days: 2));
      final sitter = HiveSeedData.createInitialSitters().first.copyWith(
        capacity: 2,
        unavailableDates: [],
      );
      final first = _request(
        'first',
        sitter,
        start,
        start.add(const Duration(days: 1)),
      ).copyWith(status: BookingStatus.confirmed);
      final second = _request(
        'second',
        sitter,
        first.endDate,
        end,
      ).copyWith(status: BookingStatus.confirmed);
      expect(
        BookingPolicy.available(
          sitter: sitter,
          start: start,
          end: end,
          now: start.subtract(const Duration(days: 1)),
          bookings: [first, second],
        ),
        isTrue,
      );
      expect(
        BookingPolicy.available(
          sitter: sitter.copyWith(capacity: 1),
          start: start,
          end: end,
          now: start.subtract(const Duration(days: 1)),
          bookings: [first],
        ),
        isFalse,
      );
    },
  );

  test(
    'Changed listing price and forged negative totals never create bookings',
    () async {
      final discovery = DiscoveryController();
      addTearDown(discovery.dispose);
      const sitters = SitterRepository();
      final sitter = sitters.getPrimarySitter();
      final start = _futureDay();
      final end = start.add(const Duration(days: 1));
      final before = BookingRepository().getAllBookings().length;
      await sitters.saveSitter(
        sitter.copyWith(pricePerUnit: 500.50, unavailableDates: []),
      );
      for (final amount in [-1.0, 500.0]) {
        await expectLater(
          discovery.submitBookingRequest(
            sitter: sitter,
            dog: HiveSeedData.initialDog,
            startDate: start,
            endDate: end,
            selectedUnits: 1,
            totalPrice: amount,
            careNotes: '',
          ),
          throwsArgumentError,
        );
      }
      final saved = await discovery.submitBookingRequest(
        sitter: sitter,
        dog: HiveSeedData.initialDog,
        startDate: start,
        endDate: end,
        selectedUnits: 1,
        totalPrice: 550.50,
        careNotes: '',
      );
      expect(saved.totalPrice, 550.50);
      expect(saved.unitPriceCents, 50050);
      expect(saved.serviceFeeCents, 5000);
      expect(saved.petId, HiveSeedData.initialDog.id);
      expect(saved.serviceType, ServiceType.hotel);
      expect(BookingRepository().getAllBookings(), hasLength(before + 1));
    },
  );

  test(
    'Duplicate submission is blocked while the first write is pending',
    () async {
      final repository = _SlowCreation();
      final discovery = DiscoveryController(bookingRepository: repository);
      addTearDown(discovery.dispose);
      final sitter = const SitterRepository().getPrimarySitter();
      final start = _futureDay();
      Future<BookingRequest> submit() => discovery.submitBookingRequest(
        sitter: sitter,
        dog: HiveSeedData.initialDog,
        startDate: start,
        endDate: start.add(const Duration(days: 1)),
        selectedUnits: 1,
        totalPrice: 500,
        careNotes: '',
      );
      final first = submit();
      expect(discovery.isBusy, isTrue);
      await expectLater(submit(), throwsStateError);
      repository.gate.complete();
      final saved = await first;
      expect(
        repository.getAllBookings().where((b) => b.id == saved.id),
        hasLength(1),
      );
      expect(discovery.isBusy, isFalse);
    },
  );

  test(
    'Approval rechecks blocked dates and leaves the request pending',
    () async {
      const settings = SettingsRepository();
      await settings.setUserRole(UserRole.sitter);
      const sitters = SitterRepository();
      final sitter = sitters.getPrimarySitter();
      final repository = BookingRepository();
      final start = _futureDay();
      final booking = _request(
        'blocked',
        sitter,
        start,
        start.add(const Duration(days: 1)),
      );
      await repository.addBooking(booking);
      await sitters.toggleUnavailableDate(sitter.id, start);
      await expectLater(
        repository.updateBookingStatus(booking.id, BookingStatus.confirmed),
        throwsArgumentError,
      );
      expect(repository.getById(booking.id)!.status, BookingStatus.pending);
    },
  );

  test('Two concurrent approvals cannot exceed a one-dog capacity', () async {
    const settings = SettingsRepository();
    await settings.setUserRole(UserRole.sitter);
    await settings.setActiveSitterId('sitter_2');
    final sitter = const SitterRepository().getPrimarySitter();
    final repository = BookingRepository();
    final start = _futureDay().add(const Duration(hours: 12));
    final end = start.add(const Duration(hours: 1));
    final a = _request('capacity_a', sitter, start, end);
    final b = _request('capacity_b', sitter, start, end);
    await repository.addBooking(a);
    await repository.addBooking(b);
    final results = await Future.wait(
      [a, b].map((booking) async {
        try {
          await repository.updateBookingStatus(
            booking.id,
            BookingStatus.confirmed,
          );
          return true;
        } on ArgumentError {
          return false;
        }
      }),
    );
    expect(results.where((result) => result), hasLength(1));
  });

  test('Rejected and completed requests cannot be reopened', () async {
    await const SettingsRepository().setUserRole(UserRole.sitter);
    final sitter = const SitterRepository().getPrimarySitter();
    final start = _futureDay();
    final repository = BookingRepository();
    final request = _request(
      'terminal',
      sitter,
      start,
      start.add(const Duration(days: 1)),
    );
    await repository.addBooking(request);
    await repository.updateBookingStatus(request.id, BookingStatus.rejected);
    await expectLater(
      repository.updateBookingStatus(request.id, BookingStatus.confirmed),
      throwsArgumentError,
    );
  });

  test(
    'Completion requires a finished confirmed service and persists its time',
    () async {
      await const SettingsRepository().setUserRole(UserRole.sitter);
      final sitter = const SitterRepository().getPrimarySitter();
      final start = _futureDay();
      final end = start.add(const Duration(days: 1));
      var now = start.subtract(const Duration(days: 1));
      final repository = BookingRepository(now: () => now);
      final booking = _request('complete', sitter, start, end);
      await repository.addBooking(booking);
      await repository.updateBookingStatus(booking.id, BookingStatus.confirmed);
      await expectLater(
        repository.updateBookingStatus(booking.id, BookingStatus.completed),
        throwsArgumentError,
      );
      now = end;
      await repository.updateBookingStatus(booking.id, BookingStatus.completed);
      expect(repository.getById(booking.id)!.completedAt, end);
      await expectLater(
        repository.updateBookingStatus(booking.id, BookingStatus.confirmed),
        throwsArgumentError,
      );
    },
  );

  test(
    'Owner cancellation is distinct and cannot cancel an active service',
    () async {
      final sitter = const SitterRepository().getPrimarySitter();
      final start = _futureDay();
      final end = start.add(const Duration(days: 1));
      var now = start.subtract(const Duration(days: 1));
      final repository = BookingRepository(now: () => now);
      final future = _request(
        'cancel',
        sitter,
        start,
        end,
      ).copyWith(status: BookingStatus.confirmed);
      await repository.addBooking(future);
      await repository.updateBookingStatus(future.id, BookingStatus.cancelled);
      expect(repository.getById(future.id)!.status, BookingStatus.cancelled);
      final active = future.copyWith(id: 'active');
      await repository.addBooking(active);
      now = start.add(const Duration(hours: 1));
      await expectLater(
        repository.updateBookingStatus(active.id, BookingStatus.cancelled),
        throwsArgumentError,
      );
    },
  );

  test(
    'Persisted ownership is checked even when the passed snapshot is forged',
    () async {
      final sitter = const SitterRepository().getPrimarySitter();
      final start = _futureDay();
      final repository = BookingRepository();
      final victim = _request(
        'victim',
        sitter,
        start,
        start.add(const Duration(days: 1)),
      ).copyWith(ownerId: 'different_owner');
      await repository.addBooking(victim);
      await expectLater(
        repository.updateBookingStatus(victim.id, BookingStatus.cancelled),
        throwsArgumentError,
      );
      expect(repository.getById(victim.id)!.status, BookingStatus.pending);
    },
  );

  test(
    'Rapid date toggles and listing changes preserve every changed field',
    () async {
      await const SettingsRepository().setUserRole(UserRole.sitter);
      final router = AppRouter();
      final provider = ProviderController(router: router);
      addTearDown(provider.dispose);
      addTearDown(router.dispose);
      final day = _futureDay();
      await Future.wait([
        provider.toggleUnavailableDate(day),
        provider.toggleUnavailableDate(day.add(const Duration(days: 1))),
        provider.updateListingDetails(
          facilityTitle: 'New title',
          location: 'Kadıköy',
          pricePerUnit: 450.90,
          bio: 'New bio',
        ),
      ]);
      final saved = const SitterRepository().getPrimarySitter();
      expect(
        saved.unavailableDates,
        containsAll([day, day.add(const Duration(days: 1))]),
      );
      expect(saved.facilityTitle, 'New title');
      expect(saved.pricePerUnit, 450.90);
      expect(saved.bio, 'New bio');
    },
  );

  test('A confirmed occupied day cannot be closed from the calendar', () async {
    await const SettingsRepository().setUserRole(UserRole.sitter);
    const sitters = SitterRepository();
    final sitter = sitters.getPrimarySitter();
    final day = _futureDay();
    await BookingRepository().addBooking(
      _request(
        'occupied',
        sitter,
        day,
        day.add(const Duration(days: 1)),
      ).copyWith(status: BookingStatus.confirmed),
    );
    await expectLater(
      sitters.toggleUnavailableDate(sitter.id, day),
      throwsArgumentError,
    );
    expect(sitters.getPrimarySitter().unavailableDates, isNot(contains(day)));
  });

  test(
    'Non-finite prices are rejected and fractional money is preserved',
    () async {
      const sitters = SitterRepository();
      final original = sitters.getPrimarySitter();
      for (final price in [double.nan, double.infinity, -5.0]) {
        await expectLater(
          Future<void>.sync(
            () => sitters.updateDetails(
              sitterId: original.id,
              facilityTitle: original.facilityTitle,
              location: original.location,
              pricePerUnit: price,
              bio: '',
            ),
          ),
          throwsArgumentError,
        );
      }
      expect(sitters.getPrimarySitter().pricePerUnit, original.pricePerUnit);
      expect(Money.parse('450,90'), 450.90);
      expect(Money.parse('450.90'), 450.90);
      expect(AppStrings.currencyAmount(450.90), '₺450,90');
      expect(Money.input(450.90), '450,90');
    },
  );

  test('IDs remain unique when the clock is fixed', () {
    final at = DateTime(2026, 10, 25);
    final ids = List.generate(1000, (_) => RecordId.create('book', at: at));
    expect(ids.toSet(), hasLength(ids.length));
  });

  testWidgets('The pending request shows dates and a walk shows clock times', (
    tester,
  ) async {
    final sitter = HiveSeedData.createInitialSitters()[1];
    final start = _futureDay().add(const Duration(hours: 14));
    final booking = _request(
      'visible',
      sitter,
      start,
      start.add(const Duration(hours: 2)),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: PendingBookingRequestCard(
            booking: booking,
            onApprove: () {},
            onReject: () {},
          ),
        ),
      ),
    );
    expect(
      find.text(
        AppStrings.bookingPeriod(
          booking.startDate,
          booking.endDate,
          hourly: true,
        ),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('14:00–16:00'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Failed approval never shows a success message before the write',
    (tester) async {
      await const SettingsRepository().setUserRole(UserRole.sitter);
      final router = AppRouter();
      final repository = _FailedDecision();
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
      final approve = find.text(AppStrings.approveButton).first;
      await tester.ensureVisible(approve);
      await tester.tap(approve);
      await tester.pump();
      expect(
        find.text(AppStrings.requestApprovedSnack('Barley')),
        findsNothing,
      );
      repository.gate.complete();
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.bookingSaveFailed), findsOneWidget);
      expect(
        find.text(AppStrings.requestApprovedSnack('Barley')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
      router.dispose();
    },
  );

  testWidgets('Editing another listing field preserves the fractional price', (
    tester,
  ) async {
    await const SettingsRepository().setUserRole(UserRole.sitter);
    const sitters = SitterRepository();
    await sitters.saveSitter(
      sitters.getPrimarySitter().copyWith(pricePerUnit: 450.90),
    );
    final router = AppRouter();
    final provider = ProviderController(router: router);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: SitterListingTab(
          controller: provider,
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
      ),
    );
    await tester.tap(find.text(AppStrings.editListingAndPriceButton));
    await tester.pumpAndSettle();
    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.any((field) => field.controller!.text == '450,90'), isTrue);
    await tester.tap(find.text(AppStrings.save));
    await tester.pumpAndSettle();
    expect(sitters.getPrimarySitter().pricePerUnit, 450.90);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
    router.dispose();
  });
}
