import '../models/models.dart';

abstract final class RecordValidation {
  static Object decode(String box, dynamic value) {
    if (value is! Map ||
        value['id'] is! String ||
        (value['id'] as String).trim().isEmpty) {
      throw const FormatException('Missing or invalid record identity');
    }
    switch (box) {
      case 'dogs_box':
        final dog = Dog.fromMap(value);
        if (dog.ownerId.trim().isEmpty ||
            dog.name.trim().isEmpty ||
            dog.breed.trim().isEmpty ||
            dog.ageYears < 0 ||
            dog.ageYears > 50 ||
            !dog.weightKg.isFinite ||
            dog.weightKg <= 0 ||
            dog.weightKg > 1000) {
          throw const FormatException('Invalid pet fields');
        }
        return dog;
      case 'sitters_box':
        final sitter = SitterListing.fromMap(value);
        if (!sitter.pricePerUnit.isFinite ||
            sitter.pricePerUnit < 0 ||
            !sitter.rating.isFinite ||
            !sitter.distanceKm.isFinite ||
            sitter.capacity < 1 ||
            sitter.capacity > 100) {
          throw const FormatException('Invalid listing fields');
        }
        return sitter;
      case 'bookings_box':
        if (value['startDate'] is! int ||
            value['endDate'] is! int ||
            !BookingStatus.values.any(
              (status) => status.name == value['status'],
            )) {
          throw const FormatException('Invalid booking dates/status');
        }
        final booking = BookingRequest.fromMap(value);
        if (booking.ownerId.trim().isEmpty ||
            booking.petId.trim().isEmpty ||
            booking.sitterId.trim().isEmpty ||
            booking.units < 1 ||
            booking.unitPriceCents < 0 ||
            booking.serviceFeeCents < 0 ||
            !booking.endDate.isAfter(booking.startDate) ||
            !booking.totalPrice.isFinite ||
            booking.totalPrice < 0) {
          throw const FormatException('Invalid booking fields');
        }
        return booking;
      case 'notifications_box':
        final notification = NotificationItem.fromMap(value);
        if (notification.recipientId.trim().isEmpty) {
          throw const FormatException('Invalid notification recipient');
        }
        return notification;
      case 'messages_box':
        return ChatMessage.fromMap(value);
      default:
        throw ArgumentError.value(box);
    }
  }
}

class RecordIssue {
  final String box;
  final String key;
  final String reason;
  const RecordIssue(this.box, this.key, this.reason);
}
