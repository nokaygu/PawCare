import '../../core/constants/app_strings.dart';
import 'models.dart';

enum BookingFailureCode {
  unavailable,
  priceChanged,
  invalidTransition,
  missingRecord,
}

class BookingFailure extends ArgumentError {
  final BookingFailureCode code;
  BookingFailure(this.code)
    : super(switch (code) {
        BookingFailureCode.unavailable =>
          AppStrings.bookingRangeUnavailableError,
        BookingFailureCode.priceChanged => AppStrings.bookingPriceChanged,
        _ => AppStrings.invalidBookingAction,
      });
}

class BookingQuote {
  final int units;
  final int unitPriceCents;
  final int serviceFeeCents;
  const BookingQuote({
    required this.units,
    required this.unitPriceCents,
    this.serviceFeeCents = 5000,
  });
  int get subtotalCents => units * unitPriceCents;
  int get totalCents => subtotalCents + serviceFeeCents;
  double get subtotal => subtotalCents / 100;
  double get serviceFee => serviceFeeCents / 100;
  double get total => totalCents / 100;
}

abstract final class BookingPolicy {
  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);
  static int _days(DateTime start, DateTime end) => DateTime.utc(
    end.year,
    end.month,
    end.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

  static BookingQuote quote(
    SitterListing sitter,
    DateTime start,
    DateTime end,
  ) {
    if (!sitter.pricePerUnit.isFinite ||
        sitter.pricePerUnit <= 0 ||
        sitter.pricePerUnit > 1000000 ||
        !end.isAfter(start)) {
      throw BookingFailure(BookingFailureCode.unavailable);
    }
    final duration = end.difference(start);
    final hourly = sitter.serviceType == ServiceType.walk;
    final units = hourly ? duration.inHours : _days(start, end);
    if (units < 1 ||
        units > (hourly ? 8 : 90) ||
        (hourly && duration != Duration(hours: units)) ||
        (!hourly && (day(start) != start || day(end) != end))) {
      throw BookingFailure(BookingFailureCode.unavailable);
    }
    return BookingQuote(
      units: units,
      unitPriceCents: Money.cents(sitter.pricePerUnit),
    );
  }

  static bool available({
    required SitterListing sitter,
    required DateTime start,
    required DateTime end,
    required DateTime now,
    Iterable<BookingRequest> bookings = const [],
    String? excludingId,
    bool approving = false,
  }) {
    try {
      quote(sitter, start, end);
    } on ArgumentError {
      return false;
    }
    if (!sitter.isPublished || sitter.capacity < 1 || sitter.capacity > 100) {
      return false;
    }
    if (!end.isAfter(now)) return false;
    if (!approving &&
        (sitter.serviceType == ServiceType.walk
            ? start.isBefore(now)
            : day(start).isBefore(day(now)))) {
      return false;
    }
    final first = day(start);
    final last = day(end.subtract(const Duration(microseconds: 1)));
    if (sitter.unavailableDates.any(
      (date) => !day(date).isBefore(first) && !day(date).isAfter(last),
    )) {
      return false;
    }
    // Only simultaneous occupancy counts; a checkout frees capacity immediately.
    final events = <(DateTime, int)>[];
    for (final booking in bookings) {
      if (booking.id == excludingId ||
          booking.sitterId != sitter.id ||
          booking.status != BookingStatus.confirmed ||
          !booking.startDate.isBefore(end) ||
          !booking.endDate.isAfter(start)) {
        continue;
      }
      events.add((
        booking.startDate.isBefore(start) ? start : booking.startDate,
        1,
      ));
      events.add((booking.endDate.isAfter(end) ? end : booking.endDate, -1));
    }
    events.sort((a, b) {
      final time = a.$1.compareTo(b.$1);
      return time == 0 ? a.$2.compareTo(b.$2) : time;
    });
    var occupied = 1;
    for (final event in events) {
      occupied += event.$2;
      if (occupied > sitter.capacity) return false;
    }
    return true;
  }
}
