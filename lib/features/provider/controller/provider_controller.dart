import 'package:flutter/foundation.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/lifecycle_notifier.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';
import '../../notifications/controller/notifications_controller.dart';

@immutable
class ProviderState {
  final List<BookingRequest> bookings;
  final SitterListing? _primarySitter;
  bool get hasListing => _primarySitter != null;
  SitterListing get primarySitter =>
      _primarySitter ?? (throw StateError('Listing unavailable'));
  final String sitterDisplayName;

  ProviderState({
    required List<BookingRequest> bookings,
    required this._primarySitter,
    required this.sitterDisplayName,
  }) : bookings = List.unmodifiable(bookings);

  List<BookingRequest> get pendingBookings =>
      bookings.where((b) => b.status == BookingStatus.pending).toList();

  List<BookingRequest> get confirmedBookings =>
      bookings.where((b) => b.status == BookingStatus.confirmed).toList();
  List<BookingRequest> get activeAndUpcomingBookings => confirmedBookings
      .where((booking) => booking.endDate.isAfter(DateTime.now()))
      .toList();
  List<BookingRequest> get awaitingCompletion => confirmedBookings
      .where((booking) => !booking.endDate.isAfter(DateTime.now()))
      .toList();

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
      primarySitter: primarySitter ?? _primarySitter,
      sitterDisplayName: sitterDisplayName ?? this.sitterDisplayName,
    );
  }
}

class ProviderController extends LifecycleNotifier<ProviderState> {
  final BookingRepository _bookingRepository;
  final SitterRepository _sitterRepository;
  final SettingsRepository _settingsRepository;
  final AppRouter router;
  final NotificationsController? notificationsController;
  final VoidCallback? onBookingsChanged;
  final VoidCallback? onListingsChanged;
  String? lastWarning;

  ProviderController({
    required this.router,
    BookingRepository? bookingRepository,
    SitterRepository? sitterRepository,
    SettingsRepository? settingsRepository,
    this.notificationsController,
    this.onBookingsChanged,
    this.onListingsChanged,
  }) : _bookingRepository = bookingRepository ?? BookingRepository(),
       _sitterRepository = sitterRepository ?? const SitterRepository(),
       _settingsRepository = settingsRepository ?? const SettingsRepository(),
       super(
         ProviderState(
           bookings: _loadBookings(
             bookingRepository ?? BookingRepository(),
             settingsRepository ?? const SettingsRepository(),
           ),
           primarySitter: (sitterRepository ?? const SitterRepository())
               .getById(
                 (settingsRepository ?? const SettingsRepository())
                     .getActiveSitterId(),
               ),
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
      primarySitter: _sitterRepository.getById(
        _settingsRepository.getActiveSitterId(),
      ),
      sitterDisplayName: _settingsRepository.getSitterName(),
    );
  }

  void refreshBookings() {
    value = value.copyWith(
      bookings: _loadBookings(_bookingRepository, _settingsRepository),
    );
  }

  void refreshListing() {
    value = ProviderState(
      bookings: value.bookings,
      primarySitter: _sitterRepository.getById(
        _settingsRepository.getActiveSitterId(),
      ),
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
    await runExclusive(() async {
      lastWarning = null;
      final updated = await _bookingRepository.updateBookingStatus(
        booking.id,
        newStatus,
      );
      refresh();
      onBookingsChanged?.call();

      final statusWord = switch (newStatus) {
        BookingStatus.confirmed => AppStrings.statusWordApproved,
        BookingStatus.completed => AppStrings.statusWordCompleted,
        _ => AppStrings.statusWordRejected,
      };
      try {
        await notificationsController?.addNotification(
          title: AppStrings.notifBookingStatusUpdatedTitle,
          message: AppStrings.notifBookingStatusUpdatedBody(
            updated.petName,
            updated.serviceTitle,
            statusWord,
          ),
          type: NotificationType.bookingStatusChanged,
          recipientId: updated.ownerId,
          recipientRole: UserRole.owner,
          relatedRecordId: booking.id,
        );
      } catch (_) {
        lastWarning = AppStrings.notificationDeliveryFailed;
      }
    });
  }

  Future<void> updateListingDetails({
    required String facilityTitle,
    required String location,
    required double pricePerUnit,
    required String bio,
    int? capacity,
  }) async {
    await runExclusive(() async {
      await _sitterRepository.updateDetails(
        sitterId: value.primarySitter.id,
        facilityTitle: facilityTitle,
        location: location,
        pricePerUnit: pricePerUnit,
        bio: bio,
        capacity: capacity,
      );
      refresh();
      (onListingsChanged ?? onBookingsChanged)?.call();
    });
  }

  Future<void> toggleUnavailableDate(DateTime date) async {
    await _sitterRepository.toggleUnavailableDate(value.primarySitter.id, date);
    refresh();
    (onListingsChanged ?? onBookingsChanged)?.call();
  }
}
