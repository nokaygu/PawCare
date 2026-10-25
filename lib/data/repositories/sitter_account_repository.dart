import '../../core/constants/app_strings.dart';
import '../../core/utils/record_id.dart';
import '../models/models.dart';
import 'settings_repository.dart';
import 'sitter_repository.dart';

/// Local demo accounts: a stable account is linked to exactly one listing.
class SitterAccountRepository {
  final SettingsRepository settings;
  final SitterRepository sitters;

  const SitterAccountRepository({
    this.settings = const SettingsRepository(),
    this.sitters = const SitterRepository(),
  });

  String? findByEmail(String email) =>
      settings.sitterIdsByEmail()[email.trim().toLowerCase()] as String?;

  Future<String> activate({required String email, String? name}) async {
    final knownId = findByEmail(email);
    final id = knownId ?? RecordId.create('sitter');
    if (knownId == null) {
      await sitters.saveSitter(
        _draft(id, name?.trim() ?? email.split('@').first),
      );
    }
    if (name != null) await sitters.updateSitterName(id, name.trim());
    final listing = sitters.getById(id);
    if (listing == null) throw StateError('Listing unavailable');
    await settings.activateSitter(
      sitterId: id,
      name: listing.name,
      email: email,
    );
    return id;
  }

  SitterListing _draft(String id, String name) => SitterListing(
    id: id,
    name: name,
    facilityTitle: '',
    category: AppStrings.categoryHotel,
    rating: 0,
    reviewsCount: 0,
    pricePerUnit: 0,
    unitLabel: 'gece',
    location: '',
    distanceKm: 0,
    imagePath: '',
    galleryPaths: const [],
    bio: '',
    amenities: const [],
    isVerified: false,
    isPublished: false,
    serviceType: ServiceType.hotel,
  );
}
