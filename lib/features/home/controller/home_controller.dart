import 'package:flutter/foundation.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';

class HomeController extends ValueNotifier<List<SitterListing>> {
  final SitterRepository _sitterRepository;
  final BookingRepository _bookingRepository;
  final SettingsRepository _settingsRepository;
  final AppRouter router;
  List<BookingRequest> _bookings = const <BookingRequest>[];
  String _ownerFirstName = AppStrings.defaultOwnerFallbackName;

  HomeController({
    required this.router,
    SitterRepository? sitterRepository,
    BookingRepository? bookingRepository,
    SettingsRepository? settingsRepository,
  }) : _sitterRepository = sitterRepository ?? const SitterRepository(),
       _bookingRepository = bookingRepository ?? const BookingRepository(),
       _settingsRepository = settingsRepository ?? const SettingsRepository(),
       super((sitterRepository ?? const SitterRepository()).getAllSitters()) {
    _refreshContext();
  }

  String get ownerFirstName => _ownerFirstName;

  void _refreshContext() {
    final full = _settingsRepository.getOwnerName().trim();
    _ownerFirstName = full.isEmpty
        ? AppStrings.defaultOwnerFallbackName
        : full.split(' ').first;
    final ownerId = _settingsRepository.getOwnerId();
    _bookings = List<BookingRequest>.unmodifiable(
      _bookingRepository.getAllBookings().where(
        (booking) => booking.ownerId == ownerId,
      ),
    );
  }

  BookingRequest? get activeConfirmedBooking {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _bookings.where((booking) {
      final start = DateTime(
        booking.startDate.year,
        booking.startDate.month,
        booking.startDate.day,
      );
      final end = DateTime(
        booking.endDate.year,
        booking.endDate.month,
        booking.endDate.day,
      );
      return booking.status == BookingStatus.confirmed &&
          !today.isBefore(start) &&
          !today.isAfter(end);
    }).firstOrNull;
  }

  void refreshSitters() {
    _refreshContext();
    value = List<SitterListing>.from(_sitterRepository.getAllSitters());
  }

  Future<void> switchToSitterMode() async {
    await router.setRole(UserRole.sitter);
  }

  void openPetProfileTab() {
    router.setOwnerNavIndex(2);
  }

  void openExploreTab() {
    router.setOwnerNavIndex(1);
  }
}
