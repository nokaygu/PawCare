import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/lifecycle_notifier.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../notifications/controller/notifications_controller.dart';

class BookingsController extends LifecycleNotifier<List<BookingRequest>> {
  final BookingRepository _bookingRepository;
  final SettingsRepository _settingsRepository;
  final NotificationsController? notificationsController;
  final VoidCallback? onBookingsChanged;

  BookingsController({
    BookingRepository? bookingRepository,
    SettingsRepository? settingsRepository,
    this.notificationsController,
    this.onBookingsChanged,
  }) : _bookingRepository = bookingRepository ?? BookingRepository(),
       _settingsRepository = settingsRepository ?? const SettingsRepository(),
       super(
         _loadBookings(
           bookingRepository ?? BookingRepository(),
           settingsRepository ?? const SettingsRepository(),
         ),
       );

  static List<BookingRequest> _loadBookings(
    BookingRepository repository,
    SettingsRepository settings,
  ) {
    final ownerId = settings.getOwnerId();
    return repository
        .getAllBookings()
        .where((booking) => booking.ownerId == ownerId)
        .toList();
  }

  void refresh() {
    value = _loadBookings(_bookingRepository, _settingsRepository);
  }

  Future<void> cancelBooking(BookingRequest booking) async {
    if (booking.ownerId != _settingsRepository.getOwnerId()) return;
    await runExclusive(() async {
      await _bookingRepository.updateBookingStatus(
        booking.id,
        BookingStatus.cancelled,
      );
      refresh();
      onBookingsChanged?.call();
      try {
        await notificationsController?.addNotification(
          title: AppStrings.notifBookingCancelledTitle,
          message: AppStrings.notifBookingCancelledBody(
            booking.sitterName,
            booking.petName,
          ),
          type: NotificationType.bookingStatusChanged,
          recipientId: booking.sitterId,
          recipientRole: UserRole.sitter,
          relatedRecordId: booking.id,
        );
      } catch (_) {
        lastWarning = AppStrings.notificationDeliveryFailed;
      }
    });
  }

  String? lastWarning;
}
