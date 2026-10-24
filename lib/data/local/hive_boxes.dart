import 'package:hive_flutter/hive_flutter.dart';

import 'hive_seed_data.dart';
import 'hive_identity_migration.dart';

class HiveBoxes {
  const HiveBoxes._();

  static const String dogsBoxName = 'dogs_box';
  static const String sittersBoxName = 'sitters_box';
  static const String bookingsBoxName = 'bookings_box';
  static const String notificationsBoxName = 'notifications_box';
  static const String settingsBoxName = 'settings_box';

  static Map<String, Map<String, dynamic>>? _fallbackMemory;

  static void clearFallbackMemory() {
    _fallbackMemory = null;
  }

  static Future<void> initFlutterAndOpen() async {
    await Hive.initFlutter();
    await openAndSeedBoxes();
  }

  static Future<void> openAndSeedBoxes() async {
    final dogsBox = await Hive.openBox<dynamic>(dogsBoxName);
    final sittersBox = await Hive.openBox<dynamic>(sittersBoxName);
    final bookingsBox = await Hive.openBox<dynamic>(bookingsBoxName);
    final notificationsBox = await Hive.openBox<dynamic>(notificationsBoxName);
    final settingsBox = await Hive.openBox<dynamic>(settingsBoxName);

    if (dogsBox.isEmpty) {
      await dogsBox.put(
        HiveSeedData.initialDog.id,
        HiveSeedData.initialDog.toMap(),
      );
    }

    if (sittersBox.isEmpty) {
      for (final sitter in HiveSeedData.createInitialSitters()) {
        await sittersBox.put(sitter.id, sitter.toMap());
      }
    }

    if (bookingsBox.isEmpty) {
      for (final booking in HiveSeedData.createInitialBookings()) {
        await bookingsBox.put(booking.id, booking.toMap());
      }
    }

    if (notificationsBox.isEmpty) {
      for (final item in HiveSeedData.initialNotifications) {
        await notificationsBox.put(item.id, item.toMap());
      }
    }

    await HiveIdentityMigration.apply(
      bookings: bookingsBox,
      settings: settingsBox,
      sitters: sittersBox,
    );
    clearFallbackMemory();
  }

  static Map<String, dynamic> _fallbackBox(String boxName) {
    final memory = _fallbackMemory ??= <String, Map<String, dynamic>>{};
    return memory.putIfAbsent(boxName, () => _createFallbackBox(boxName));
  }

  static Map<String, dynamic> _createFallbackBox(String boxName) {
    switch (boxName) {
      case dogsBoxName:
        return <String, dynamic>{
          HiveSeedData.initialDog.id: HiveSeedData.initialDog.toMap(),
        };
      case sittersBoxName:
        return <String, dynamic>{
          for (final sitter in HiveSeedData.createInitialSitters())
            sitter.id: sitter.toMap(),
        };
      case bookingsBoxName:
        return <String, dynamic>{
          for (final booking in HiveSeedData.createInitialBookings())
            booking.id: booking.toMap(),
        };
      case notificationsBoxName:
        return <String, dynamic>{
          for (final item in HiveSeedData.initialNotifications)
            item.id: item.toMap(),
        };
      case settingsBoxName:
        return HiveIdentityMigration.createInitialSettings();
      default:
        return <String, dynamic>{};
    }
  }

  static List<dynamic> getValues(String boxName) {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName).values.toList();
    }
    return _fallbackBox(boxName).values.toList();
  }

  static dynamic getValue(String boxName, String key, {dynamic defaultValue}) {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName).get(key, defaultValue: defaultValue);
    }
    return _fallbackBox(boxName)[key] ?? defaultValue;
  }

  static Future<void> putValue(
    String boxName,
    String key,
    dynamic value,
  ) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).put(key, value);
      return;
    }
    _fallbackBox(boxName)[key] = value;
  }
}
