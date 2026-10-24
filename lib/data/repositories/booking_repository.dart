import '../local/hive_boxes.dart';
import '../models/models.dart';
import 'record_order.dart';

class BookingRepository {
  const BookingRepository();

  List<BookingRequest> getAllBookings() {
    final rawList = HiveBoxes.getValues(HiveBoxes.bookingsBoxName);
    final list = rawList
        .map(
          (e) => BookingRequest.fromMap(Map<dynamic, dynamic>.from(e as Map)),
        )
        .toList();
    list.sort((a, b) => compareNewestRecordIds(a.id, b.id));
    return list;
  }

  Future<void> addBooking(BookingRequest booking) async {
    await HiveBoxes.putValue(
      HiveBoxes.bookingsBoxName,
      booking.id,
      booking.toMap(),
    );
  }

  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final bookings = getAllBookings();
    final idx = bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;
    final updated = bookings[idx].copyWith(status: newStatus);
    await HiveBoxes.putValue(
      HiveBoxes.bookingsBoxName,
      updated.id,
      updated.toMap(),
    );
  }
}
