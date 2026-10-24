import 'package:flutter/foundation.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';
import '../../notifications/controller/notifications_controller.dart';

@immutable
class ProviderState {
  final List<BookingRequest> bookings;
  final SitterListing primarySitter;
  final String sitterDisplayName;

  const ProviderState({
    required this.bookings,
    required this.primarySitter,
    required this.sitterDisplayName,
  });

  List<BookingRequest> get pendingBookings =>
      bookings.where((b) => b.status == BookingStatus.pending).toList();

  List<BookingRequest> get confirmedBookings =>
      bookings.where((b) => b.status == BookingStatus.confirmed).toList();

  double get totalConfirmedEarnings {
    final now = DateTime.now();
    return confirmedBookings
        .where((booking) {
          return booking.startDate.year == now.year &&
              booking.startDate.month == now.month;
        })
        .fold<double>(0.0, (sum, booking) => sum + booking.totalPrice);
  }

  ProviderState copyWith({
    List<BookingRequest>? bookings,
    SitterListing? primarySitter,
    String? sitterDisplayName,
  }) {
    return ProviderState(
      bookings: bookings ?? this.bookings,
      primarySitter: primarySitter ?? this.primarySitter,
      sitterDisplayName: sitterDisplayName ?? this.sitterDisplayName,
    );
  }
}

class ProviderController extends ValueNotifier<ProviderState> {
  final BookingRepository _bookingRepository;
  final SitterRepository _sitterRepository;
  final SettingsRepository _settingsRepository;
  final AppRouter router;
  final NotificationsController? notificationsController;
  final VoidCallback? onBookingsChanged;

  ProviderController({
    required this.router,
    BookingRepository? bookingRepository,
    SitterRepository? sitterRepository,
    SettingsRepository? settingsRepository,
    this.notificationsController,
    this.onBookingsChanged,
  }) : _bookingRepository = bookingRepository ?? const BookingRepository(),
       _sitterRepository = sitterRepository ?? const SitterRepository(),
       _settingsRepository = settingsRepository ?? const SettingsRepository(),
       super(
         ProviderState(
           bookings: _loadBookings(
             bookingRepository ?? const BookingRepository(),
             settingsRepository ?? const SettingsRepository(),
           ),
           primarySitter: (sitterRepository ?? const SitterRepository())
               .getPrimarySitter(),
           sitterDisplayName: (settingsRepository ?? const SettingsRepository())
               .getSitterName(),
         ),
       );

  static List<BookingRequest> _loadBookings(
    BookingRepository repository,
    SettingsRepository settings,
  ) {
    final sitterId = settings.getActiveSitterId();
    return repository
        .getAllBookings()
        .where((booking) => booking.sitterId == sitterId)
        .toList();
  }

  void refresh() {
    value = ProviderState(
      bookings: _loadBookings(_bookingRepository, _settingsRepository),
      primarySitter: _sitterRepository.getPrimarySitter(),
      sitterDisplayName: _settingsRepository.getSitterName(),
    );
  }

  Future<void> switchToOwnerMode() async {
    await router.setRole(UserRole.owner);
  }

  Future<void> updateBookingStatus(
    BookingRequest booking,
    BookingStatus newStatus,
  ) async {
    if (booking.sitterId != _settingsRepository.getActiveSitterId()) return;
    await _bookingRepository.updateBookingStatus(booking.id, newStatus);
    refresh();
    onBookingsChanged?.call();

    final statusWord = newStatus == BookingStatus.confirmed
        ? AppStrings.statusWordApproved
        : AppStrings.statusWordRejected;
    await notificationsController?.addNotification(
      title: AppStrings.notifBookingStatusUpdatedTitle,
      message: AppStrings.notifBookingStatusUpdatedBody(
        booking.petName,
        booking.serviceTitle,
        statusWord,
      ),
      type: NotificationType.bookingStatusChanged,
    );
  }

  Future<void> updateListingDetails({
    required String facilityTitle,
    required String location,
    required double pricePerUnit,
    required String bio,
  }) async {
    final current = value.primarySitter;
    final updated = current.copyWith(
      facilityTitle: facilityTitle.trim().isEmpty
          ? current.facilityTitle
          : facilityTitle.trim(),
      location: location.trim().isEmpty ? current.location : location.trim(),
      pricePerUnit: pricePerUnit <= 0 ? current.pricePerUnit : pricePerUnit,
      bio: bio.trim().isEmpty ? current.bio : bio.trim(),
    );
    await _sitterRepository.saveSitter(updated);
    refresh();
    onBookingsChanged?.call();
  }

  Future<void> toggleUnavailableDate(DateTime date) async {
    final current = List<DateTime>.from(value.primarySitter.unavailableDates);
    final idx = current.indexWhere(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
    );
    if (idx != -1) {
      current.removeAt(idx);
    } else {
      current.add(date);
    }
    final updated = value.primarySitter.copyWith(unavailableDates: current);
    await _sitterRepository.saveSitter(updated);
    refresh();
    onBookingsChanged?.call();
  }
}
