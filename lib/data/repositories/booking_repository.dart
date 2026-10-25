import '../local/hive_boxes.dart';
import '../models/models.dart';
import '../models/booking_policy.dart';
import 'record_order.dart';
import 'settings_repository.dart';
import 'sitter_repository.dart';

class BookingRepository {
  final DateTime Function() _now;
  final SettingsRepository settings;
  final SitterRepository sitters;
  (int, int)? _cachedRevision;
  List<BookingRequest> _cached = const [];

  BookingRepository({
    DateTime Function()? now,
    this.settings = const SettingsRepository(),
    this.sitters = const SitterRepository(),
  }) : _now = now ?? DateTime.now;

  BookingRequest? getById(String id) {
    return HiveBoxes.readRecord<BookingRequest>(HiveBoxes.bookingsBoxName, id);
  }

  List<BookingRequest> getAllBookings() {
    final revision = HiveBoxes.revision(HiveBoxes.bookingsBoxName);
    if (_cachedRevision == revision) return _cached;
    final list = HiveBoxes.readRecords<BookingRequest>(
      HiveBoxes.bookingsBoxName,
    );
    list.sort((a, b) {
      final comparison = b.createdAt.compareTo(a.createdAt);
      if (comparison != 0) return comparison;
      return compareNewestRecordIds(a.id, b.id);
    });
    _cachedRevision = revision;
    return _cached = List.unmodifiable(list);
  }

  bool isPhotoReferenced(String path) =>
      HiveBoxes.getValues(HiveBoxes.bookingsBoxName)
          .any((raw) => raw is Map && raw['petPhotoPath'] == path);

  Future<void> addBooking(BookingRequest booking) async {
    if (getById(booking.id) != null) {
      throw BookingFailure(BookingFailureCode.invalidTransition);
    }
    await HiveBoxes.putValue(
      HiveBoxes.bookingsBoxName,
      booking.id,
      booking.toMap(),
    );
  }

  Future<BookingRequest> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final initial = getById(bookingId);
    if (initial == null) throw BookingFailure(BookingFailureCode.missingRecord);
    final role = settings.getUserRole();
    final actorId = role == UserRole.owner
        ? settings.getOwnerId()
        : settings.getActiveSitterId();
    return HiveBoxes.runLocked(
      'booking_capacity_${initial.sitterId}',
      () async {
        final current = getById(bookingId);
        if (current == null) {
          throw BookingFailure(BookingFailureCode.missingRecord);
        }
        final activeId = role == UserRole.owner
            ? settings.getOwnerId()
            : settings.getActiveSitterId();
        if (settings.getUserRole() != role || activeId != actorId) {
          throw BookingFailure(BookingFailureCode.invalidTransition);
        }
        final now = _now();
        if (newStatus == BookingStatus.cancelled) {
          if (role != UserRole.owner ||
              actorId != current.ownerId ||
              !current.canCancelAt(now)) {
            throw BookingFailure(BookingFailureCode.invalidTransition);
          }
        } else {
          if (role != UserRole.sitter || actorId != current.sitterId) {
            throw BookingFailure(BookingFailureCode.invalidTransition);
          }
          _validateProviderTransition(current, newStatus, now);
        }
        final updated = current.copyWith(
          status: newStatus,
          completedAt: newStatus == BookingStatus.completed ? now : null,
        );
        await HiveBoxes.putValue(
          HiveBoxes.bookingsBoxName,
          updated.id,
          updated.toMap(),
        );
        return updated;
      },
    );
  }

  void _validateProviderTransition(
    BookingRequest booking,
    BookingStatus status,
    DateTime now,
  ) {
    if (status == BookingStatus.completed) {
      if (booking.status != BookingStatus.confirmed ||
          now.isBefore(booking.endDate)) {
        throw BookingFailure(BookingFailureCode.invalidTransition);
      }
      return;
    }
    if (booking.status != BookingStatus.pending ||
        (status != BookingStatus.confirmed &&
            status != BookingStatus.rejected)) {
      throw BookingFailure(BookingFailureCode.invalidTransition);
    }
    if (status == BookingStatus.rejected) return;
    final sitter = sitters.getById(booking.sitterId);
    if (sitter == null ||
        !BookingPolicy.available(
          sitter: sitter,
          start: booking.startDate,
          end: booking.endDate,
          now: now,
          bookings: getAllBookings(),
          excludingId: booking.id,
          approving: true,
        )) {
      throw BookingFailure(BookingFailureCode.unavailable);
    }
  }
}
