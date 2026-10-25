import 'dart:async';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/lifecycle_notifier.dart';
import '../../../data/models/models.dart';
import '../../../data/models/home_state.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/dog_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';
import '../../pets/controller/pets_controller.dart';

class HomeController extends LifecycleNotifier<HomeState> {
  final SitterRepository _sitterRepository;
  final BookingRepository _bookingRepository;
  final SettingsRepository _settingsRepository;
  final PetsController? _petsController;
  final DateTime Function() _now;
  final AppRouter router;
  List<BookingRequest> _bookings = const [];
  List<SitterListing> _featured = const [];
  String _ownerFirstName = AppStrings.defaultOwnerFallbackName;
  Timer? _boundaryTimer;

  HomeController({
    required this.router,
    SitterRepository? sitterRepository,
    BookingRepository? bookingRepository,
    SettingsRepository? settingsRepository,
    this._petsController,
    DateTime Function()? now,
  }) : _sitterRepository = sitterRepository ?? const SitterRepository(),
       _bookingRepository = bookingRepository ?? BookingRepository(),
       _settingsRepository = settingsRepository ?? const SettingsRepository(),
       _now = now ?? DateTime.now,
       super(
         HomeState(
           ownerFirstName: AppStrings.defaultOwnerFallbackName,
           evaluatedAt: (now ?? DateTime.now)(),
         ),
       ) {
    refreshSitters();
    _petsController?.addListener(refreshTime);
  }

  String get ownerFirstName => value.ownerFirstName;
  BookingRequest? get activeConfirmedBooking => value.activeBooking;

  void refreshOwner() {
    final name = _settingsRepository.getOwnerName().trim();
    _ownerFirstName = name.isEmpty
        ? AppStrings.defaultOwnerFallbackName
        : name.split(' ').first;
    refreshTime();
  }

  void refreshBookings() {
    final ownerId = _settingsRepository.getOwnerId();
    _bookings = _bookingRepository
        .getAllBookings()
        .where((b) => b.ownerId == ownerId)
        .toList();
    refreshOwner();
  }

  void _loadCatalog() {
    final listings = List<SitterListing>.of(_sitterRepository.getAllSitters())
      ..sort((a, b) {
        final rating = b.rating.compareTo(a.rating);
        return rating == 0 ? a.id.compareTo(b.id) : rating;
      });
    _featured = List.unmodifiable(listings.take(3));
  }

  void refreshSitters() {
    _loadCatalog();
    refreshBookings();
  }

  void refreshListings() {
    _loadCatalog();
    refreshTime();
  }

  void refreshTime() {
    if (isDisposed) return;
    final now = _now();
    final ownerId = _settingsRepository.getOwnerId();
    final pet = _petsController == null
        ? const DogRepository().findCurrentDog()
        : _petsController.value;
    final selected = pet?.ownerId == ownerId ? pet : null;
    final records =
        _bookings
            .where(
              (b) =>
                  b.ownerId == ownerId &&
                  selected != null &&
                  b.petId == selected.id,
            )
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final active = records.where((b) => b.isActiveAt(now)).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
    final next = records
        .where(
          (b) =>
              b.status == BookingStatus.confirmed && b.startDate.isAfter(now),
        )
        .toList();
    value = HomeState(
      ownerFirstName: _ownerFirstName,
      selectedDog: selected,
      evaluatedAt: now,
      featuredSitters: _featured,
      activeBooking: active.firstOrNull,
      nextBooking: next.firstOrNull,
      pendingCount: records
          .where((b) => b.status == BookingStatus.pending)
          .length,
      otherBookingCount: (active.length + next.length - 1).clamp(
        0,
        records.length,
      ),
    );
    _scheduleBoundary(now);
  }

  void _scheduleBoundary(DateTime now) {
    _boundaryTimer?.cancel();
    var next = DateTime(now.year, now.month, now.day + 1);
    for (final booking in _bookings) {
      for (final boundary in [booking.startDate, booking.endDate]) {
        if (boundary.isAfter(now) && boundary.isBefore(next)) next = boundary;
      }
    }
    _boundaryTimer = Timer(
      next.difference(now) + const Duration(milliseconds: 10),
      () {
        if (isDisposed) return;
        _petsController?.refreshTime();
        refreshTime();
      },
    );
  }

  Future<void> switchToSitterMode() => router.setRole(UserRole.sitter);
  void openExploreTab() => router.setOwnerNavIndex(1);
  void openBookingsTab() => router.setOwnerNavIndex(3);

  @override
  void dispose() {
    _boundaryTimer?.cancel();
    _petsController?.removeListener(refreshTime);
    super.dispose();
  }
}
