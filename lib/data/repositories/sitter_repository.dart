import '../local/hive_boxes.dart';
import '../models/models.dart';
import '../../core/constants/app_strings.dart';
import 'settings_repository.dart';

class SitterRepository {
  final SettingsRepository settingsRepository;

  const SitterRepository({
    this.settingsRepository = const SettingsRepository(),
  });

  List<SitterListing> getAllSitters() {
    return HiveBoxes.readRecords<SitterListing>(
      HiveBoxes.sittersBoxName,
      where: (raw) => raw['isPublished'] != false,
    ).where((sitter) => sitter.isPublished).toList();
  }

  bool isPhotoReferenced(String path) =>
      HiveBoxes.getValues(HiveBoxes.sittersBoxName).any(
        (raw) =>
            raw is Map &&
            (raw['imagePath'] == path ||
                (raw['galleryPaths'] is List &&
                    (raw['galleryPaths'] as List).contains(path))),
      );

  SitterListing? getById(String id) {
    return HiveBoxes.readRecord<SitterListing>(HiveBoxes.sittersBoxName, id);
  }

  SitterListing getPrimarySitter() {
    final sitterId = settingsRepository.getActiveSitterId();
    return getById(sitterId) ?? (throw StateError('Listing not found'));
  }

  Future<void> updateSitterName(String sitterId, String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    await HiveBoxes.mutateValue(HiveBoxes.sittersBoxName, sitterId, (raw) {
      if (raw is! Map) throw StateError('Listing not found');
      return SitterListing.fromMap(raw).copyWith(name: cleanName).toMap();
    });
  }

  List<BookingRequest> _confirmedFor(String sitterId) =>
      HiveBoxes.readRecords<BookingRequest>(
        HiveBoxes.bookingsBoxName,
        where: (raw) =>
            raw['sitterId'] == sitterId &&
            raw['status'] == BookingStatus.confirmed.name,
      );

  Future<void> updateDetails({
    required String sitterId,
    required String facilityTitle,
    required String location,
    required double pricePerUnit,
    required String bio,
    int? capacity,
  }) {
    if (!pricePerUnit.isFinite || pricePerUnit <= 0 || pricePerUnit > 1000000) {
      throw ArgumentError(AppStrings.invalidPrice);
    }
    if (capacity != null && (capacity < 1 || capacity > 100)) {
      throw ArgumentError(AppStrings.invalidCapacity);
    }
    return HiveBoxes.runLocked('booking_capacity_$sitterId', () async {
      await HiveBoxes.mutateValue(HiveBoxes.sittersBoxName, sitterId, (raw) {
        if (settingsRepository.getActiveSitterId() != sitterId || raw is! Map) {
          throw StateError('Listing unavailable');
        }
        final current = SitterListing.fromMap(raw);
        final title = facilityTitle.trim().isEmpty
            ? current.facilityTitle
            : facilityTitle.trim();
        final place = location.trim().isEmpty
            ? current.location
            : location.trim();
        if (title.isEmpty || place.isEmpty) {
          throw ArgumentError(AppStrings.authErrorEmptyFields);
        }
        final nextCapacity = capacity ?? current.capacity;
        final events = <(DateTime, int)>[];
        for (final booking in _confirmedFor(sitterId)) {
          if (!booking.endDate.isAfter(DateTime.now())) continue;
          events.add((booking.startDate, 1));
          events.add((booking.endDate, -1));
        }
        events.sort(
          (a, b) => a.$1 == b.$1 ? a.$2.compareTo(b.$2) : a.$1.compareTo(b.$1),
        );
        var occupied = 0;
        for (final event in events) {
          occupied += event.$2;
          if (occupied > nextCapacity) {
            throw ArgumentError(AppStrings.invalidCapacity);
          }
        }
        return current
            .copyWith(
              facilityTitle: title,
              location: place,
              pricePerUnit: Money.cents(pricePerUnit) / 100,
              bio: bio.trim(),
              capacity: nextCapacity,
              isPublished: true,
            )
            .toMap();
      });
    });
  }

  Future<void> toggleUnavailableDate(
    String sitterId,
    DateTime date,
  ) => HiveBoxes.runLocked('booking_capacity_$sitterId', () async {
    await HiveBoxes.mutateValue(HiveBoxes.sittersBoxName, sitterId, (raw) {
      if (raw is! Map || settingsRepository.getActiveSitterId() != sitterId) {
        throw StateError('Listing unavailable');
      }
      final sitter = SitterListing.fromMap(raw);
      final day = DateTime(date.year, date.month, date.day);
      final current = List<DateTime>.of(sitter.unavailableDates);
      final index = current.indexWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,
      );
      if (index >= 0) {
        current.removeAt(index);
      } else {
        final end = DateTime(day.year, day.month, day.day + 1);
        if (_confirmedFor(sitterId).any(
          (booking) =>
              booking.startDate.isBefore(end) && booking.endDate.isAfter(day),
        )) {
          throw ArgumentError(AppStrings.bookingRangeUnavailableError);
        }
        current.add(day);
      }
      return sitter.copyWith(unavailableDates: current).toMap();
    });
  });

  Future<void> saveSitter(SitterListing sitter) async {
    await HiveBoxes.putValue(
      HiveBoxes.sittersBoxName,
      sitter.id,
      sitter.toMap(),
    );
  }
}
