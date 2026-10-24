import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';
import '../../notifications/controller/notifications_controller.dart';

@immutable
class DiscoveryFilterState {
  final String selectedCategory;
  final String searchQuery;
  final double maxPrice;
  final bool sortByPriceAsc;
  final List<SitterListing> allSitters;

  const DiscoveryFilterState({
    this.selectedCategory = AppStrings.categoryAll,
    this.searchQuery = '',
    this.maxPrice = 1500.0,
    this.sortByPriceAsc = false,
    required this.allSitters,
  });

  List<SitterListing> get filteredSitters {
    final q = searchQuery.toLowerCase();
    final filtered = allSitters.where((s) {
      final matchesCategory =
          selectedCategory == AppStrings.categoryAll ||
          s.category == selectedCategory;
      final matchesSearch =
          searchQuery.isEmpty ||
          s.name.toLowerCase().contains(q) ||
          s.facilityTitle.toLowerCase().contains(q) ||
          s.location.toLowerCase().contains(q);
      final matchesPrice = s.pricePerUnit <= maxPrice;
      return matchesCategory && matchesSearch && matchesPrice;
    }).toList();

    if (sortByPriceAsc) {
      filtered.sort((a, b) => a.pricePerUnit.compareTo(b.pricePerUnit));
    } else {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return filtered;
  }

  DiscoveryFilterState copyWith({
    String? selectedCategory,
    String? searchQuery,
    double? maxPrice,
    bool? sortByPriceAsc,
    List<SitterListing>? allSitters,
  }) {
    return DiscoveryFilterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      maxPrice: maxPrice ?? this.maxPrice,
      sortByPriceAsc: sortByPriceAsc ?? this.sortByPriceAsc,
      allSitters: allSitters ?? this.allSitters,
    );
  }
}

class DiscoveryController extends ValueNotifier<DiscoveryFilterState> {
  final SitterRepository _sitterRepository;
  final BookingRepository _bookingRepository;
  final SettingsRepository _settingsRepository;
  final NotificationsController? notificationsController;
  final VoidCallback? onBookingsUpdated;

  DiscoveryController({
    SitterRepository? sitterRepository,
    BookingRepository? bookingRepository,
    SettingsRepository? settingsRepository,
    this.notificationsController,
    this.onBookingsUpdated,
  }) : _sitterRepository = sitterRepository ?? const SitterRepository(),
       _bookingRepository = bookingRepository ?? const BookingRepository(),
       _settingsRepository = settingsRepository ?? const SettingsRepository(),
       super(
         DiscoveryFilterState(
           allSitters: (sitterRepository ?? const SitterRepository())
               .getAllSitters(),
         ),
       );

  void refreshSitters() {
    value = value.copyWith(allSitters: _sitterRepository.getAllSitters());
  }

  void setCategory(String category) {
    value = value.copyWith(selectedCategory: category);
  }

  void setSearchQuery(String query) {
    value = value.copyWith(searchQuery: query);
  }

  void setMaxPrice(double price) {
    value = value.copyWith(maxPrice: price);
  }

  void setSortByPriceAsc(bool asc) {
    value = value.copyWith(sortByPriceAsc: asc);
  }

  void resetFilters() {
    value = DiscoveryFilterState(allSitters: _sitterRepository.getAllSitters());
  }

  bool isBookingRangeAvailable({
    required SitterListing sitter,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (start.isBefore(today) || end.isBefore(start)) return false;
    return !sitter.unavailableDates.any((date) {
      final day = DateTime(date.year, date.month, date.day);
      return !day.isBefore(start) && !day.isAfter(end);
    });
  }

  Future<BookingRequest> submitBookingRequest({
    required SitterListing sitter,
    required Dog dog,
    required DateTime startDate,
    required DateTime endDate,
    required int selectedUnits,
    required double totalPrice,
    required String careNotes,
  }) async {
    final currentSitter =
        _sitterRepository
            .getAllSitters()
            .where((item) => item.id == sitter.id)
            .firstOrNull ??
        sitter;
    if (!isBookingRangeAvailable(
      sitter: currentSitter,
      startDate: startDate,
      endDate: endDate,
    )) {
      throw ArgumentError(AppStrings.bookingRangeUnavailableError);
    }
    final ownerFirstName = _settingsRepository
        .getOwnerName()
        .trim()
        .split(' ')
        .first;
    final booking = BookingRequest(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      sitterId: sitter.id,
      sitterName: currentSitter.name,
      sitterPhoto: currentSitter.imagePath,
      petName: dog.name,
      petBreed: dog.breed,
      petPhotoPath: dog.photoPath,
      ownerName: ownerFirstName.isEmpty
          ? AppStrings.defaultOwnerFallbackName
          : ownerFirstName,
      ownerId: _settingsRepository.getOwnerId(),
      serviceTitle: AppStrings.bookingServiceSummary(
        sitter.category,
        selectedUnits,
        sitter.unitLabel,
      ),
      startDate: startDate,
      endDate: endDate,
      totalPrice: totalPrice,
      careNotes: careNotes,
      status: BookingStatus.pending,
    );

    await _bookingRepository.addBooking(booking);
    await notificationsController?.addNotification(
      title: AppStrings.notifBookingCreatedTitle,
      message: AppStrings.notifBookingCreatedBody(
        currentSitter.name,
        currentSitter.facilityTitle,
        dog.name,
      ),
      type: NotificationType.bookingCreated,
    );
    onBookingsUpdated?.call();
    return booking;
  }
}
