import 'package:hive_flutter/hive_flutter.dart';

import 'hive_seed_data.dart';
import 'record_validation.dart';
import 'history_maintenance.dart';
import '../models/conversation_identity.dart';

class HiveBoxes {
  const HiveBoxes._();

  static const String dogsBoxName = 'dogs_box';
  static const String sittersBoxName = 'sitters_box';
  static const String bookingsBoxName = 'bookings_box';
  static const String notificationsBoxName = 'notifications_box';
  static const String settingsBoxName = 'settings_box';
  static const String conversationsBoxName = 'conversations_box';
  static const String messagesBoxName = 'messages_box';
  static const String archiveBoxName = 'history_archive_box';
  static const String quarantineBoxName = 'quarantine_box';
  static final Map<String, RecordIssue> _issues = {};
  static List<RecordIssue> get issues => List.unmodifiable(_issues.values);

  static Map<String, Map<String, dynamic>>? _fallbackMemory;
  static final Map<String, Future<void>> _pendingWrites = {};
  static final Map<String, int> _revisions = {};
  static int _generation = 0;
  static bool _requiresPersistentStorage = false;

  static (int, int) revision(String boxName) =>
      (_generation, _revisions[boxName] ?? 0);

  /// One serial writer per record/resource. Finished operations leave no entry.
  static Future<T> runLocked<T>(String resource, Future<T> Function() action) {
    final previous = _pendingWrites[resource] ?? Future<void>.value();
    final operation = previous.then((_) => action());
    late final Future<void> settled;
    void release() {
      if (identical(_pendingWrites[resource], settled)) {
        _pendingWrites.remove(resource);
      }
    }

    settled = operation.then<void>(
      (_) => release(),
      onError: (Object _, StackTrace _) => release(),
    );
    _pendingWrites[resource] = settled;
    return operation;
  }

  static Future<void> mutateValue(
    String boxName,
    String key,
    dynamic Function(dynamic current) update,
  ) => runLocked('$boxName/$key', () async {
    final updated = update(getValue(boxName, key));
    await putValue(boxName, key, updated);
  });

  static void clearFallbackMemory() {
    _fallbackMemory = null;
    _issues.clear();
    _requiresPersistentStorage = false;
    _generation++;
    _revisions.clear();
  }

  static Future<void> initFlutterAndOpen() async {
    _requiresPersistentStorage = true;
    await Hive.initFlutter();
    await openAndSeedBoxes();
  }

  static Future<Box<dynamic>> _openBoxSafely(String boxName) async {
    try {
      return await Hive.openBox<dynamic>(boxName);
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {}
      return await Hive.openBox<dynamic>(boxName);
    }
  }

  static Future<LazyBox<dynamic>> _openLazyBoxSafely(String boxName) async {
    try {
      return await Hive.openLazyBox<dynamic>(boxName);
    } catch (_) {
      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {}
      return await Hive.openLazyBox<dynamic>(boxName);
    }
  }

  static Future<void> openAndSeedBoxes() async {
    _requiresPersistentStorage = true;
    final dogsBox = await _openBoxSafely(dogsBoxName);
    final sittersBox = await _openBoxSafely(sittersBoxName);
    final bookingsBox = await _openBoxSafely(bookingsBoxName);
    final notificationsBox = await _openBoxSafely(notificationsBoxName);
    final settingsBox = await _openBoxSafely(settingsBoxName);

    final conversationsBox = await _openBoxSafely(conversationsBoxName);
    final messagesBox = await _openLazyBoxSafely(messagesBoxName);
    final archiveBox = await _openLazyBoxSafely(archiveBoxName);

    await _openLazyBoxSafely(quarantineBoxName);

    final needsDemoSeed = settingsBox.get('initial_data_created') != true;
    if (needsDemoSeed) {
      for (final box in [
        dogsBox,
        sittersBox,
        bookingsBox,
        notificationsBox,
        conversationsBox,
        settingsBox,
      ]) {
        if (box.isEmpty) await box.putAll(_initialRecords(box.name));
      }
      if (messagesBox.isEmpty) {
        await messagesBox.putAll(_initialRecords(messagesBoxName));
      }
    }

    _issues.clear();
    await quarantineInvalidRows();
    await _validateSettings(settingsBox);
    await HistoryMaintenance.archiveReadNotifications(
      active: notificationsBox,
      archive: archiveBox,
    );
    if (needsDemoSeed) await settingsBox.put('initial_data_created', true);
    _fallbackMemory = null;
    _generation++;
    _revisions.clear();
  }

  static Future<void> _validateSettings(Box<dynamic> settings) async {
    final types = <String, bool Function(dynamic)>{
      'is_dark_mode': (v) => v is bool,
      'user_role': (v) => v is String && ['owner', 'sitter'].contains(v),
      'owner_id': (v) => v is String && v.isNotEmpty,
      'active_sitter_id': (v) => v is String && v.isNotEmpty,
      'user_name': (v) => v is String,
      'user_email': (v) => v is String,
      'welcome_completed': (v) => v is bool,
      'sitter_profile_${settings.get('active_sitter_id')}': (v) =>
          v is Map && v['name'] is String && v['email'] is String,
      'owner_profiles': (v) =>
          v is Map &&
          v.values.every(
            (p) => p is Map && p['name'] is String && p['email'] is String,
          ),
      'owner_ids_by_email': (v) =>
          v is Map && v.values.every((id) => id is String),
      'sitter_ids_by_email': (v) =>
          v is Map && v.values.every((id) => id is String),
    };
    final defaults = HiveSeedData.createInitialSettings();
    for (final entry in types.entries) {
      if (!settings.containsKey(entry.key) && defaults.containsKey(entry.key)) {
        await settings.put(entry.key, defaults[entry.key]);
      }
      final raw = settings.get(entry.key);
      if (entry.value(raw)) continue;
      await Hive.lazyBox<dynamic>(quarantineBoxName).put(
        '$settingsBoxName/${entry.key}',
        {'sourceBox': settingsBoxName, 'sourceKey': entry.key, 'raw': raw},
      );
      throw FormatException('Invalid persisted setting: ${entry.key}');
    }
    if (settings.get('user_role') == 'sitter') {
      final id = settings.get('active_sitter_id') as String;
      if (readRecord<Object>(sittersBoxName, id) == null) {
        throw const FormatException('Active listing cannot be read');
      }
    }
  }

  static Map<String, dynamic> _fallbackBox(String boxName) {
    if (_requiresPersistentStorage) {
      throw StateError('Persistent storage unavailable: $boxName');
    }
    final memory = _fallbackMemory ??= <String, Map<String, dynamic>>{};
    return memory.putIfAbsent(boxName, () => _initialRecords(boxName));
  }

  static Map<String, dynamic> _initialRecords(String boxName) {
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
      case messagesBoxName:
        final thread = ConversationIdentity.key(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_2',
        );
        return {
          for (var i = 0; i < HiveSeedData.initialChatMessages.length; i++)
            '$thread/$i': HiveSeedData.initialChatMessages[i].toMap(),
        };
      case conversationsBoxName:
        return {
          ConversationIdentity.key(
            ownerId: HiveSeedData.demoOwnerId,
            sitterId: 'sitter_2',
          ): {
            'count': HiveSeedData.initialChatMessages.length,
          },
        };
      case settingsBoxName:
        return HiveSeedData.createInitialSettings();
      default:
        return <String, dynamic>{};
    }
  }

  static Object? _decode(String boxName, String key, dynamic raw) {
    if (raw == null) return null;
    try {
      final value = RecordValidation.decode(boxName, raw);
      _issues.remove('$boxName/$key');
      return value;
    } catch (error) {
      if (_issues.length < 100) {
        _issues['$boxName/$key'] = RecordIssue(
          boxName,
          key,
          error.runtimeType.toString(),
        );
      }
      return null;
    }
  }

  static T? readRecord<T>(String boxName, String key) =>
      _decode(boxName, key, getValue(boxName, key)) as T?;

  static List<T> readRecords<T>(
    String boxName, {
    bool Function(Map raw)? where,
  }) {
    final box = Hive.isBoxOpen(boxName) ? Hive.box<dynamic>(boxName) : null;
    final keys = box?.keys ?? _fallbackBox(boxName).keys;
    final result = <T>[];
    for (final key in keys) {
      final raw = box == null ? _fallbackBox(boxName)[key] : box.get(key);
      if (where != null && raw is Map && !where(raw)) {
        continue;
      }
      final decoded = _decode(boxName, key.toString(), raw);
      if (decoded is T) result.add(decoded);
    }
    return result;
  }

  static Future<void> quarantineInvalidRows() async {
    for (final boxName in [
      dogsBoxName,
      sittersBoxName,
      bookingsBoxName,
      notificationsBoxName,
    ]) {
      if (!Hive.isBoxOpen(boxName)) continue;
      final box = Hive.box<dynamic>(boxName);
      for (final key in box.keys) {
        final raw = box.get(key);
        if (_decode(boxName, key.toString(), raw) != null) continue;
        await Hive.lazyBox<dynamic>(quarantineBoxName).put('$boxName/$key', {
          'sourceBox': boxName,
          'sourceKey': key,
          'raw': raw,
          'detectedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }
  }

  static Iterable<dynamic> historyKeys(String boxName) =>
      Hive.isBoxOpen(boxName)
      ? Hive.lazyBox<dynamic>(boxName).keys
      : _fallbackBox(boxName).keys;

  static Future<dynamic> getHistoryValue(String boxName, String key) async {
    if (Hive.isBoxOpen(boxName)) return Hive.lazyBox<dynamic>(boxName).get(key);
    return _fallbackBox(boxName)[key];
  }

  static Future<void> deleteValue(String boxName, String key) async {
    if (Hive.isBoxOpen(boxName)) {
      if (boxName == messagesBoxName ||
          boxName == archiveBoxName ||
          boxName == quarantineBoxName) {
        await Hive.lazyBox<dynamic>(boxName).delete(key);
      } else {
        await Hive.box<dynamic>(boxName).delete(key);
      }
    } else {
      _fallbackBox(boxName).remove(key);
    }
    _revisions[boxName] = (_revisions[boxName] ?? 0) + 1;
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

  static Future<void> putValues(
    String boxName,
    Map<String, dynamic> values,
  ) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).putAll(values);
    } else {
      _fallbackBox(boxName).addAll(values);
    }
    _revisions[boxName] = (_revisions[boxName] ?? 0) + 1;
  }

  static Future<void> putValue(
    String boxName,
    String key,
    dynamic value,
  ) async {
    if (Hive.isBoxOpen(boxName)) {
      if (boxName == messagesBoxName ||
          boxName == archiveBoxName ||
          boxName == quarantineBoxName) {
        await Hive.lazyBox<dynamic>(boxName).put(key, value);
      } else {
        await Hive.box<dynamic>(boxName).put(key, value);
      }
      _revisions[boxName] = (_revisions[boxName] ?? 0) + 1;
      return;
    }
    _fallbackBox(boxName)[key] = value;
    _revisions[boxName] = (_revisions[boxName] ?? 0) + 1;
  }
}
