import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/widgets/modals/live_tracking_modal.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/calendar_date.dart';
import 'package:paw_care/data/models/health_summary.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/dog_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/auth/controller/auth_controller.dart';
import 'package:paw_care/features/discovery/controller/discovery_controller.dart';
import 'package:paw_care/features/home/controller/home_controller.dart';
import 'package:paw_care/features/home/widgets/owner_home_sections.dart';
import 'package:paw_care/features/pets/controller/pets_controller.dart';
import 'package:paw_care/features/pets/widgets/dog_editor_modal.dart';
import 'package:paw_care/features/pets/widgets/dog_form_modals.dart';
import 'package:paw_care/features/pets/widgets/health_card_modal.dart';
import 'package:paw_care/features/provider/controller/provider_controller.dart';

final _today = DateTime(2026, 10, 25, 12);
Vaccination _v(String id, String date, {bool completed = false}) => Vaccination(
  id: id,
  title: id,
  dueAt: CalendarDate.tryParse(date),
  vetName: '',
  status: completed ? VaccineStatus.completed : VaccineStatus.upcoming,
);
Dog _dog(List<Vaccination> records) =>
    HiveSeedData.initialDog.copyWith(vaccinations: records);
BookingRequest _booking(
  String id,
  DateTime start,
  DateTime end, {
  String petId = 'dog_1',
  BookingStatus status = BookingStatus.confirmed,
  ServiceType type = ServiceType.walk,
}) => HiveSeedData.createInitialBookings().first.copyWith(
  id: id,
  ownerId: const SettingsRepository().getOwnerId(),
  petId: petId,
  petName: 'Aynı isim',
  sitterName: 'İlgili bakıcı',
  startDate: start,
  endDate: end,
  status: status,
  serviceType: type,
);
Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

class _CountedBookings extends BookingRepository {
  int reads = 0;
  @override
  List<BookingRequest> getAllBookings() {
    reads++;
    return super.getAllBookings();
  }
}

class _LargeCatalog extends SitterRepository {
  @override
  List<SitterListing> getAllSitters() => List.generate(
    1000,
    (i) => HiveSeedData.createInitialSitters().first.copyWith(
      id: 's_$i',
      rating: i / 1000,
    ),
  );
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  test('Civil dates accept only the current ISO representation', () {
    expect(CalendarDate.tryParse('2024-02-29'), DateTime(2024, 2, 29));
    for (final date in [
      '2025-02-29',
      '2026-04-31',
      '2026-13-01',
      '2026-1-1',
      '29.02.2024',
      'yarın',
    ]) {
      expect(CalendarDate.tryParse(date), isNull);
    }
    expect(CalendarDate.tryParse('25 Ekim 2026'), isNull);
    expect(CalendarDate.tryParse('25 October 2026'), isNull);
    final record = _v('v', '2026-10-25');
    expect(record.toMap()['dueOn'], '2026-10-25');
    expect(Vaccination.fromMap(record.toMap()).dueAt, DateTime(2026, 10, 25));
    expect(
      () => Vaccination.fromMap(record.toMap()..remove('dueOn')),
      throwsFormatException,
    );
    expect(
      () => Vaccination.fromMap(record.toMap()..['dueOn'] = '25 Ekim 2026'),
      throwsFormatException,
    );
  });

  test('Empty health records never imply completed care', () {
    expect(
      HealthSummary.forDog(_dog([]), _today).kind,
      HealthSummaryKind.noRecords,
    );
    expect(
      HealthSummary.forDog(null, _today).kind,
      HealthSummaryKind.noRecords,
    );
  });
  test('Overdue wins over future records and the earliest date wins', () {
    final health = HealthSummary.forDog(
      _dog([
        _v('far', '2027-01-01'),
        _v('late', '2026-10-20'),
        _v('oldest', '2026-10-01'),
        _v('done', '2026-01-01', completed: true),
      ]),
      _today,
    );
    expect(health.kind, HealthSummaryKind.overdue);
    expect(health.primary!.id, 'oldest');
    expect(health.overdueCount, 2);
    expect(health.daysUntil, -24);
  });
  test('Upcoming care sorts by date; all completed and unknown dates stay distinct', () {
    final health = HealthSummary.forDog(
      _dog([_v('far', '2027-01-01'), _v('near', '2026-10-26')]),
      _today,
    );
    expect(health.primary!.id, 'near');
    expect(health.daysUntil, 1);
    expect(
      HealthSummary.forDog(_dog([_v('x', 'bad')]), _today).kind,
      HealthSummaryKind.unknownDates,
    );
    expect(
      HealthSummary.forDog(
        _dog([_v('x', 'bad', completed: true)]),
        _today,
      ).kind,
      HealthSummaryKind.completed,
    );
  });
  test('Completion stores the actual time; undo clears it; midnight derives overdue', () async {
    await const DogRepository().saveDog(_dog([_v('v', '2026-10-25')]));
    var now = _today;
    final pets = PetsController(now: () => now);
    addTearDown(pets.dispose);
    await pets.toggleVaccinationStatus('v');
    expect(pets.currentDog.vaccinations.single.completedAt, now);
    await pets.toggleVaccinationStatus('v');
    expect(pets.currentDog.vaccinations.single.completedAt, isNull);
    expect(pets.currentDog.vaccinations.single.completionDate, isNull);
    expect(pets.healthSummary.kind, HealthSummaryKind.upcoming);
    now = DateTime(2026, 10, 26);
    pets.refreshTime();
    expect(pets.healthSummary.kind, HealthSummaryKind.overdue);
  });
  test('Invalid vaccine date and invalid pet fields do not persist', () async {
    final pets = PetsController();
    addTearDown(pets.dispose);
    final before = pets.currentDog.toMap();
    await expectLater(
      pets.addVaccination(title: 'Bad', dueAt: DateTime(1800), vetName: ''),
      throwsArgumentError,
    );
    for (final weight in [0.0, -1.0, double.nan, double.infinity]) {
      await expectLater(
        pets.updateDog(pets.currentDog.copyWith(weightKg: weight)),
        throwsArgumentError,
      );
    }
    await expectLater(
      pets.updateDog(pets.currentDog.copyWith(name: '')),
      throwsArgumentError,
    );
    await expectLater(
      pets.updateDog(pets.currentDog.copyWith(ageYears: -1)),
      throwsArgumentError,
    );
    expect(pets.currentDog.toMap(), before);
  });
  test('New pet has no invented health or identity data; optional fields can clear', () async {
    final pets = PetsController();
    addTearDown(pets.dispose);
    await pets.addNewDog(
      name: 'Yeni',
      breed: 'Melez',
      ageYears: 1,
      weightKg: 5,
      gender: '',
      microchip: '',
      allergyNote: '',
      behaviorNote: '',
      clinicName: '',
      clinicPhone: '',
    );
    expect(pets.currentDog.vaccinations, isEmpty);
    expect(pets.currentDog.microchip, isEmpty);
    expect(pets.currentDog.photoPath, isEmpty);
    expect(pets.currentDog.clinicName, isEmpty);
    await pets.updateDog(
      pets.currentDog.copyWith(allergyNote: 'Eski', nutritionPlan: 'Plan'),
    );
    await pets.updateDog(
      pets.currentDog.copyWith(allergyNote: '', nutritionPlan: ''),
    );
    expect(const DogRepository().getCurrentDog().allergyNote, isEmpty);
    expect(const DogRepository().getCurrentDog().nutritionPlan, isEmpty);
    final existingChip = HiveSeedData.initialDog.microchip;
    await expectLater(
      pets.updateDog(pets.currentDog.copyWith(microchip: existingChip)),
      throwsArgumentError,
    );
  });

  test(
    'Same-name pets keep bookings separated by required pet identity',
    () async {
      const dogs = DogRepository();
      final repo = BookingRepository();
      await dogs.saveDog(HiveSeedData.initialDog.copyWith(name: 'Aynı isim'));
      await dogs.saveDog(
        HiveSeedData.initialDog.copyWith(
          id: 'second',
          name: 'Aynı isim',
          microchip: '',
        ),
      );
      await repo.addBooking(
        _booking(
          'first',
          _today.subtract(const Duration(hours: 1)),
          _today.add(const Duration(hours: 1)),
        ),
      );
      await repo.addBooking(
        _booking(
          'second',
          _today.subtract(const Duration(hours: 1)),
          _today.add(const Duration(hours: 2)),
          petId: 'second',
        ),
      );
      final pets = PetsController(now: () => _today);
      final router = AppRouter();
      final home = HomeController(
        router: router,
        petsController: pets,
        now: () => _today,
      );
      addTearDown(home.dispose);
      addTearDown(pets.dispose);
      addTearDown(router.dispose);
      expect(home.value.activeBooking!.id, 'first');
      await pets.selectDog('second');
      expect(home.value.activeBooking!.id, 'second');
      await pets.updateDog(pets.currentDog.copyWith(name: 'Yeni isim'));
      expect(home.value.activeBooking!.id, 'second');
    },
  );
  test('Home observes exact start/end boundaries, prioritizes ending work, and counts extras', () async {
    final ownerId = await const SettingsRepository().activateOwner(
      email: 'clock@example.com',
    );
    await const DogRepository().saveDog(
      HiveSeedData.initialDog.copyWith(id: 'clock_pet', ownerId: ownerId),
    );
    await const DogRepository().setActiveDog('clock_pet');
    final repo = _CountedBookings();
    var now = _today;
    await repo.addBooking(
      _booking('ended', DateTime(2026, 10, 25, 8), now, petId: 'clock_pet'),
    );
    await repo.addBooking(
      _booking(
        'night',
        DateTime(2026, 10, 24),
        DateTime(2026, 10, 26),
        type: ServiceType.hotel,
        petId: 'clock_pet',
      ),
    );
    await repo.addBooking(
      _booking(
        'walk',
        now,
        now.add(const Duration(hours: 1)),
        petId: 'clock_pet',
      ),
    );
    await repo.addBooking(
      _booking(
        'future',
        now.add(const Duration(hours: 2)),
        now.add(const Duration(hours: 3)),
        petId: 'clock_pet',
      ),
    );
    await repo.addBooking(
      _booking(
        'pending',
        now,
        now.add(const Duration(hours: 1)),
        status: BookingStatus.pending,
        petId: 'clock_pet',
      ),
    );
    final router = AppRouter();
    final home = HomeController(
      router: router,
      bookingRepository: repo,
      now: () => now,
    );
    addTearDown(home.dispose);
    addTearDown(router.dispose);
    expect(home.value.activeBooking!.id, 'walk');
    expect(home.value.nextBooking!.id, 'future');
    expect(home.value.otherBookingCount, 2);
    expect(home.value.pendingCount, 1);
    final reads = repo.reads;
    now = DateTime(2026, 10, 25, 13);
    home.refreshTime();
    expect(home.value.activeBooking!.id, 'night');
    now = DateTime(2026, 10, 25, 14);
    home.refreshTime();
    expect(home.value.activeBooking!.id, 'future');
    now = DateTime(2026, 10, 26);
    home.refreshTime();
    expect(home.value.activeBooking, isNull);
    expect(home.value.nextBooking, isNull);
    expect(repo.reads, reads);
  });
  test(
    'A large catalog yields only the three highest rated featured listings',
    () {
      final router = AppRouter();
      final home = HomeController(
        router: router,
        sitterRepository: _LargeCatalog(),
        now: () => _today,
      );
      addTearDown(home.dispose);
      addTearDown(router.dispose);
      expect(home.value.featuredSitters.map((s) => s.id), [
        's_999',
        's_998',
        's_997',
      ]);
    },
  );

  for (final type in [ServiceType.hotel, ServiceType.dayCare]) {
    testWidgets(
      '${type.name} offers reservation details without walk tracking',
      (tester) async {
        final booking = _booking(
          'b',
          _today.subtract(const Duration(hours: 1)),
          _today.add(const Duration(hours: 1)),
          type: type,
        );
        await tester.pumpWidget(
          _host(
            TodaysReservationLiveCard(
              activeBooking: booking,
              now: _today,
              onExplore: () {},
              onOpenBookings: () {},
            ),
          ),
        );
        expect(find.text(AppStrings.liveTrackingButton), findsNothing);
        expect(find.text(AppStrings.viewReservation), findsOneWidget);
        expect(find.text(booking.petName), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets(
    'Future walk is upcoming without an active badge; live demo uses its actual pair',
    (tester) async {
      final booking = _booking(
        'b',
        _today.add(const Duration(hours: 1)),
        _today.add(const Duration(hours: 2)),
      );
      await tester.pumpWidget(
        _host(
          TodaysReservationLiveCard(
            activeBooking: booking,
            now: _today,
            onExplore: () {},
          ),
        ),
      );
      expect(find.text(AppStrings.upcomingReservationTitle), findsOneWidget);
      expect(find.text(AppStrings.activeReservationBadge), findsNothing);
      expect(find.text(AppStrings.liveTrackingButton), findsNothing);
      await tester.pumpWidget(_host(LiveTrackingModal(booking: booking)));
      expect(find.textContaining(booking.sitterName), findsWidgets);
      expect(find.textContaining(booking.petName), findsWidgets);
      expect(find.textContaining('Mert & Barley'), findsNothing);
    },
  );
  testWidgets('Both health surfaces warn about overdue records', (
    tester,
  ) async {
    await const DogRepository().saveDog(_dog([_v('Geciken', '2026-10-01')]));
    final pets = PetsController(now: () => _today);
    addTearDown(pets.dispose);
    await tester.pumpWidget(
      _host(UpcomingVaccineAlertCard(petsController: pets)),
    );
    expect(
      find.text(AppStrings.overdueVaccineTitle('Geciken')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.allVaccinesCompletedTitle), findsNothing);
    await tester.pumpWidget(_host(HealthCardModal(petsController: pets)));
    expect(
      find.text(AppStrings.overdueVaccineTitle('Geciken')),
      findsOneWidget,
    );
    expect(find.text(AppStrings.allVaccinesCompletedTitle), findsNothing);
  });
  testWidgets(
    'Blank pet form remains open on invalid save and has no demo defaults',
    (tester) async {
      final pets = PetsController();
      addTearDown(pets.dispose);
      await tester.pumpWidget(_host(DogEditorModal(controller: pets)));
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      expect(fields.every((f) => f.controller!.text.isEmpty), isTrue);
      await tester.ensureVisible(find.text(AppStrings.save));
      await tester.tap(find.text(AppStrings.save));
      await tester.pumpAndSettle();
      expect(find.byType(DogEditorModal), findsOneWidget);
      expect(pets.allDogs.length, 1);
      expect(find.text(AppStrings.invalidPetFields), findsOneWidget);
    },
  );
  for (final width in [320.0, 360.0]) {
    testWidgets(
      'Long name fits a $width wide home card at increased text scale',
      (tester) async {
        tester.view.physicalSize = Size(width, 1500);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final pets = PetsController();
        addTearDown(pets.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, 1500),
                textScaler: const TextScaler.linear(1.3),
              ),
              child: Scaffold(
                body: DogQuickProfileCard(
                  dog: pets.currentDog.copyWith(
                    name: 'Çok Uzun Bir Köpek İsmi Olan Dostumuz',
                  ),
                  petsController: pets,
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('Identity is a text card and unverified listings have no badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(MicrochipIdentityModal(dog: HiveSeedData.initialDog)),
    );
    expect(find.byIcon(Icons.qr_code_2), findsNothing);
    expect(find.text(HiveSeedData.initialDog.microchip), findsOneWidget);
    await tester.pumpWidget(
      _host(
        FeaturedSittersSection(
          sitters: [
            HiveSeedData.createInitialSitters().first.copyWith(
              isVerified: false,
            ),
          ],
          onSeeAll: () {},
          onSitterTap: (_) {},
        ),
      ),
    );
    expect(find.byIcon(Icons.verified), findsNothing);
  });
  test('Immutable state takes defensive copies at every list boundary', () {
    final vaccines = [_v('v', '2026-10-25')];
    final dog = _dog(vaccines);
    vaccines.clear();
    expect(dog.vaccinations, hasLength(1));
    expect(() => dog.vaccinations.clear(), throwsUnsupportedError);
    final dates = [DateTime(2026, 10, 25)];
    final sitter = HiveSeedData.createInitialSitters().first.copyWith(
      unavailableDates: dates,
    );
    dates.clear();
    expect(sitter.unavailableDates, hasLength(1));
    expect(() => sitter.galleryPaths.clear(), throwsUnsupportedError);
    expect(() => sitter.amenities.clear(), throwsUnsupportedError);
    final listings = [sitter];
    final discovery = DiscoveryFilterState(allSitters: listings);
    listings.clear();
    expect(discovery.allSitters, hasLength(1));
    expect(() => discovery.allSitters.clear(), throwsUnsupportedError);
    final bookings = [
      _booking('b', _today, _today.add(const Duration(hours: 1))),
    ];
    final state = ProviderState(
      primarySitter: sitter,
      sitterDisplayName: sitter.name,
      bookings: bookings,
    );
    bookings.clear();
    expect(state.bookings, hasLength(1));
    expect(() => state.bookings.clear(), throwsUnsupportedError);
  });
  test(
    'Invalid email and short demo password do not create an identity',
    () async {
      final router = AppRouter();
      final auth = AuthController(router: router);
      addTearDown(auth.dispose);
      addTearDown(router.dispose);
      final before = const SettingsRepository().getOwnerId();
      expect(await auth.login(email: 'invalid', password: 'password'), isFalse);
      expect(
        await auth.signUp(
          name: 'Test',
          email: 'test@example.com',
          password: 'short',
          confirmPassword: 'short',
          role: UserRole.owner,
        ),
        isFalse,
      );
      expect(const SettingsRepository().getOwnerId(), before);
    },
  );
  test('Returning sitter A keeps their own profile after visiting B and restarting Hive', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pawcare_sitter_return_',
    );
    final router = AppRouter();
    final auth = AuthController(router: router);
    try {
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      for (final name in ['Alpha', 'Beta']) {
        expect(
          await auth.signUp(
            name: name,
            email: '$name@sitter.test',
            password: 'password',
            confirmPassword: 'password',
            role: UserRole.sitter,
          ),
          isTrue,
        );
      }
      await auth.login(email: 'alpha@sitter.test', password: 'password');
      final id = const SettingsRepository().getActiveSitterId();
      await Hive.close();
      await HiveBoxes.openAndSeedBoxes();
      expect(const SettingsRepository().getActiveSitterId(), id);
      expect(const SettingsRepository().getSitterName(), 'Alpha');
      expect(const SitterRepository().getPrimarySitter().name, 'Alpha');
      expect(const SettingsRepository().getSitterEmail(), 'alpha@sitter.test');
    } finally {
      auth.dispose();
      router.dispose();
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
