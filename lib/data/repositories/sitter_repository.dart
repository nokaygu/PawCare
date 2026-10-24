import '../local/hive_boxes.dart';
import '../local/hive_seed_data.dart';
import '../models/models.dart';
import 'settings_repository.dart';

class SitterRepository {
  final SettingsRepository settingsRepository;

  const SitterRepository({
    this.settingsRepository = const SettingsRepository(),
  });

  List<SitterListing> getAllSitters() {
    final rawList = HiveBoxes.getValues(HiveBoxes.sittersBoxName);
    if (rawList.isEmpty) {
      return HiveSeedData.createInitialSitters();
    }
    return rawList
        .map((e) => SitterListing.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  SitterListing getPrimarySitter() {
    final sitterId = settingsRepository.getActiveSitterId();
    return getAllSitters().firstWhere((sitter) => sitter.id == sitterId);
  }

  Future<void> updateSitterName(String sitterId, String name) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    final sitter = getAllSitters().firstWhere((entry) => entry.id == sitterId);
    if (sitter.name == cleanName) return;
    await saveSitter(sitter.copyWith(name: cleanName));
  }

  Future<void> saveSitter(SitterListing sitter) async {
    await HiveBoxes.putValue(
      HiveBoxes.sittersBoxName,
      sitter.id,
      sitter.toMap(),
    );
  }
}
