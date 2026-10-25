import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/lifecycle_notifier.dart';
import '../../../core/utils/record_id.dart';
import '../../../core/utils/search_text.dart';

import '../../../data/models/models.dart';
import '../../../data/models/booking_policy.dart';
import '../../../data/repositories/dog_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';
import '../../notifications/controller/notifications_controller.dart';

class _SearchEntry {
  final SitterListing sitter;
  final String text;
  _SearchEntry(this.sitter)
    : text = SearchText.normalize(
        '${sitter.name} ${sitter.facilityTitle} ${sitter.location}',
      );
}

@immutable
class DiscoveryFilterState {
  final String selectedCategory;
  final String searchQuery;
  final double? maxPrice;
  final bool sortByPriceAsc;
  final List<SitterListing> allSitters;
  final List<_SearchEntry> _index;
  late final List<SitterListing> filteredSitters = _filter();

  DiscoveryFilterState({
    this.selectedCategory = AppStrings.categoryAll,
    this.searchQuery = '',
    this.maxPrice,
    this.sortByPriceAsc = false,
    required List<SitterListing> allSitters,
  }) : allSitters = List.unmodifiable(allSitters),
       _index = List.unmodifiable(allSitters.map(_SearchEntry.new));

  DiscoveryFilterState._({
    required this.selectedCategory,
    required this.searchQuery,
    required this.maxPrice,
    required this.sortByPriceAsc,
    required this.allSitters,
    required this._index,
  });

  List<SitterListing> _filter() {
    final query = SearchText.normalize(searchQuery);
    final filtered = _index
        .where((entry) {
          final sitter = entry.sitter;
          return (selectedCategory == AppStrings.categoryAll ||
                  sitter.category == selectedCategory) &&
              (query.isEmpty || entry.text.contains(query)) &&
              (maxPrice == null || sitter.pricePerUnit <= maxPrice!);
        })
        .map((entry) => entry.sitter)
        .toList();
    filtered.sort((a, b) {
      final result = sortByPriceAsc
          ? a.pricePerUnit.compareTo(b.pricePerUnit)
          : b.rating.compareTo(a.rating);
      return result == 0 ? a.id.compareTo(b.id) : result;
    });
    return List.unmodifiable(filtered);
  }

  DiscoveryFilterState copyWith({
    String? selectedCategory,
    String? searchQuery,
    double? maxPrice,
    bool clearPrice = false,
    bool? sortByPriceAsc,
    List<SitterListing>? allSitters,
  }) {
    if (allSitters != null) {
      return DiscoveryFilterState(
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
        maxPrice: clearPrice ? null : maxPrice ?? this.maxPrice,
        sortByPriceAsc: sortByPriceAsc ?? this.sortByPriceAsc,
        allSitters: allSitters,
      );
    }
    return DiscoveryFilterState._(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      maxPrice: clearPrice ? null : maxPrice ?? this.maxPrice,
      sortByPriceAsc: sortByPriceAsc ?? this.sortByPriceAsc,
      allSitters: this.allSitters,
      index: _index,
    );
  }
}

class DiscoveryController extends LifecycleNotifier<DiscoveryFilterState> {
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
       _bookingRepository = bookingRepository ?? BookingRepository(),
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
    if (query == value.searchQuery) return;
    value = value.copyWith(searchQuery: query);
  }

  void setMaxPrice(double? price) {
    value = value.copyWith(maxPrice: price, clearPrice: price == null);
  }

  void setSortByPriceAsc(bool asc) {
    value = value.copyWith(sortByPriceAsc: asc);
  }

  void applyFilters({double? maxPrice, required bool sortByPriceAsc}) {
    value = value.copyWith(
      maxPrice: maxPrice,
      clearPrice: maxPrice == null,
      sortByPriceAsc: sortByPriceAsc,
    );
  }

  void resetFilters() {
    value = DiscoveryFilterState(allSitters: value.allSitters);
  }

  bool isBookingRangeAvailable({
    required SitterListing sitter,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return BookingPolicy.available(
      sitter: sitter,
      start: startDate,
      end: endDate,
      now: DateTime.now(),
      bookings: _bookingRepository.getAllBookings(),
    );
  }

  BookingQuote quote(SitterListing sitter, DateTime start, DateTime end) =>
      BookingPolicy.quote(sitter, start, end);

  String? lastWarning;

  Future<BookingRequest> submitBookingRequest({
    required SitterListing sitter,
    required Dog dog,
    required DateTime startDate,
    required DateTime endDate,
    required int selectedUnits,
    required double totalPrice,
    required String careNotes,
  }) async {
    return runExclusive(() async {
      lastWarning = null;
      final currentSitter = _sitterRepository.getById(sitter.id);
      final ownerId = _settingsRepository.getOwnerId();
      if (currentSitter == null ||
          !currentSitter.isPublished ||
          dog.ownerId != ownerId ||
          const DogRepository().getById(dog.id) == null) {
        throw BookingFailure(BookingFailureCode.missingRecord);
      }
      if (!isBookingRangeAvailable(
        sitter: currentSitter,
        startDate: startDate,
        endDate: endDate,
      )) {
        throw BookingFailure(BookingFailureCode.unavailable);
      }
      final offer = quote(currentSitter, startDate, endDate);
      if (selectedUnits != offer.units ||
          Money.cents(totalPrice) != offer.totalCents) {
        throw BookingFailure(BookingFailureCode.priceChanged);
      }
      final ownerFirstName = _settingsRepository
          .getOwnerName()
          .trim()
          .split(' ')
          .first;
      final booking = BookingRequest(
        id: RecordId.create('book'),
        sitterId: sitter.id,
        sitterName: currentSitter.name,
        sitterPhoto: currentSitter.imagePath,
        petName: dog.name,
        petBreed: dog.breed,
        petPhotoPath: dog.photoPath,
        ownerName: ownerFirstName.isEmpty
            ? AppStrings.defaultOwnerFallbackName
            : ownerFirstName,
        ownerId: ownerId,
        petId: dog.id,
        serviceType: currentSitter.serviceType,
        units: offer.units,
        unitPriceCents: offer.unitPriceCents,
        serviceFeeCents: offer.serviceFeeCents,
        createdAt: DateTime.now(),
        serviceTitle: AppStrings.bookingServiceSummary(
          currentSitter.serviceType.category,
          offer.units,
          currentSitter.serviceType.unit,
        ),
        startDate: startDate,
        endDate: endDate,
        totalPrice: offer.total,
        careNotes: careNotes,
        status: BookingStatus.pending,
      );

      await _bookingRepository.addBooking(booking);
      onBookingsUpdated?.call();
      try {
        await notificationsController?.addNotification(
          title: AppStrings.notifBookingCreatedTitle,
          message: AppStrings.notifBookingCreatedBody(
            currentSitter.name,
            currentSitter.facilityTitle,
            dog.name,
          ),
          type: NotificationType.bookingCreated,
          recipientId: currentSitter.id,
          recipientRole: UserRole.sitter,
          relatedRecordId: booking.id,
        );
      } catch (_) {
        lastWarning = AppStrings.notificationDeliveryFailed;
      }
      return booking;
    });
  }
}
