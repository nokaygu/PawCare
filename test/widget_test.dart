import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/app.dart';
import 'package:paw_care/core/widgets/paw_bottom_nav.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/dog_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);
  test('Domain models serialize and deserialize via toMap and fromMap', () {
    final dog = HiveSeedData.initialDog;
    final dogRestored = Dog.fromMap(dog.toMap());
    expect(dogRestored.id, dog.id);
    expect(dogRestored.name, 'Barley');
    expect(dogRestored.vaccinations.length, dog.vaccinations.length);

    final sitter = HiveSeedData.createInitialSitters().first;
    final sitterRestored = SitterListing.fromMap(sitter.toMap());
    expect(sitterRestored.id, sitter.id);
    expect(sitterRestored.facilityTitle, sitter.facilityTitle);
    expect(
      sitterRestored.unavailableDates.length,
      sitter.unavailableDates.length,
    );

    final booking = HiveSeedData.createInitialBookings().first;
    final bookingRestored = BookingRequest.fromMap(booking.toMap());
    expect(bookingRestored.id, booking.id);
    expect(bookingRestored.status, BookingStatus.pending);

    final notif = HiveSeedData.initialNotifications.first;
    final notifRestored = NotificationItem.fromMap(notif.toMap());
    expect(notifRestored.id, notif.id);
    expect(notifRestored.type, NotificationType.bookingCreated);
  });

  test('Repositories persist and update state properly', () async {
    const dogRepo = DogRepository();
    final bookingRepo = BookingRepository();
    const settingsRepo = SettingsRepository();

    final initialDog = dogRepo.getCurrentDog();
    expect(initialDog.name, 'Barley');

    await settingsRepo.setIsDarkMode(true);
    expect(settingsRepo.getIsDarkMode(), isTrue);
    await settingsRepo.setIsDarkMode(false);
    expect(settingsRepo.getIsDarkMode(), isFalse);

    final bookingsBefore = bookingRepo.getAllBookings().length;
    await bookingRepo.addBooking(
      BookingRequest(
        id: 'test_book_99',
        ownerId: settingsRepo.getOwnerId(),
        ownerName: settingsRepo.getOwnerName(),
        petId: initialDog.id,
        serviceType: ServiceType.hotel,
        units: 2,
        unitPriceCents: 45000,
        serviceFeeCents: 5000,
        createdAt: DateTime(2026, 10, 23),
        sitterId: 'sitter_1',
        sitterName: 'Ayşe Yılmaz',
        sitterPhoto: 'assets/images/ayse.jpg',
        petName: 'Barley',
        petBreed: 'Golden Retriever',
        serviceTitle: 'Köpek Oteli (2 Gece)',
        startDate: DateTime(2026, 10, 24),
        endDate: DateTime(2026, 10, 26),
        totalPrice: 950,
        careNotes: 'Test notu',
        status: BookingStatus.pending,
      ),
    );
    expect(bookingRepo.getAllBookings().length, bookingsBefore + 1);
  });

  testWidgets('PawCareApp renders Owner Home and switches to Sitter mode', (
    WidgetTester tester,
  ) async {
    const settingsRepo = SettingsRepository();
    await settingsRepo.setUserRole(UserRole.owner);

    await tester.pumpWidget(const PawCareApp());
    await tester.pump();

    expect(find.byType(PawCareApp), findsOneWidget);
    expect(find.textContaining('Aygen'), findsWidgets);
    expect(find.textContaining('Barley'), findsWidgets);
    expect(find.byType(PawBottomNav), findsOneWidget);

    await tester.tap(find.text('Hizmet Veren'));
    await tester.pump();

    expect(find.textContaining('Ayşe Yılmaz'), findsOneWidget);
    expect(find.textContaining('Yeni Gelen Talepler'), findsOneWidget);
  });
}
