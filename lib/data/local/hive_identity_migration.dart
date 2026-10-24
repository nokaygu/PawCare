import 'package:hive/hive.dart';

import '../../core/constants/app_strings.dart';
import '../models/models.dart';
import 'hive_seed_data.dart';

abstract final class HiveIdentityMigration {
  static Map<String, dynamic> createInitialSettings() => <String, dynamic>{
    'owner_id': ConversationIdentity.legacyOwnerId,
    'active_sitter_id': 'sitter_1',
    'owner_ids_by_email': <String, String>{
      AppStrings.defaultOwnerEmail: ConversationIdentity.legacyOwnerId,
    },
    'owner_profiles': <String, dynamic>{
      ConversationIdentity.legacyOwnerId: <String, String>{
        'name': AppStrings.defaultOwnerFullName,
        'email': AppStrings.defaultOwnerEmail,
      },
    },
    _chatKey(ConversationIdentity.legacyOwnerId, 'sitter_2'): HiveSeedData
        .initialChatMessages
        .map((message) => message.toMap())
        .toList(),
  };

  static String _chatKey(String ownerId, String sitterId) =>
      'chat_messages_${ConversationIdentity.key(ownerId: ownerId, sitterId: sitterId)}';

  static Future<void> apply({
    required Box<dynamic> bookings,
    required Box<dynamic> settings,
    required Box<dynamic> sitters,
  }) async {
    final ownerId =
        settings.get('owner_id') as String? ??
        ConversationIdentity.legacyOwnerId;
    final email =
        settings.get('user_email') as String? ?? AppStrings.defaultOwnerEmail;
    final defaults = createInitialSettings();
    defaults['owner_id'] = ownerId;
    defaults['owner_ids_by_email'] = <String, String>{
      AppStrings.defaultOwnerEmail: ConversationIdentity.legacyOwnerId,
      email.trim().toLowerCase(): ownerId,
    };
    defaults['owner_profiles'] = <String, dynamic>{
      ownerId: <String, String>{
        'name':
            settings.get('user_name') as String? ??
            AppStrings.defaultOwnerFullName,
        'email': email,
      },
    };
    for (final key in <String>[
      'owner_id',
      'active_sitter_id',
      'owner_ids_by_email',
      'owner_profiles',
    ]) {
      if (!settings.containsKey(key)) await settings.put(key, defaults[key]);
    }
    for (final key in bookings.keys.toList()) {
      final raw = bookings.get(key);
      if (raw is! Map) continue;
      final savedOwnerId = raw['ownerId'] as String?;
      if (savedOwnerId != null && savedOwnerId.trim().isNotEmpty) continue;
      final migrated = Map<dynamic, dynamic>.from(raw);
      final savedOwnerName = _normalizeOwnerName(
        settings.get('user_name') as String? ?? AppStrings.defaultOwnerFullName,
      );
      final bookingOwnerName = _normalizeOwnerName(raw['ownerName'] as String?);
      final currentOwnerAliases = _ownerAliases(savedOwnerName);
      migrated['ownerId'] = currentOwnerAliases.contains(bookingOwnerName)
          ? ownerId
          : ConversationIdentity.ownerIdForLegacyBooking(
              ownerName: raw['ownerName'] as String?,
              bookingId: raw['id'] as String? ?? key.toString(),
            );
      await bookings.put(key, migrated);
    }
    await _migrateChats(settings, sitters);
    await _recoverSitterName(settings, sitters);
  }

  static Future<void> _migrateChats(
    Box<dynamic> settings,
    Box<dynamic> sitters,
  ) async {
    final legacyScopedKeys = settings.keys
        .whereType<String>()
        .where((key) => key.startsWith('chat_messages_sitter_'))
        .toList();
    final hadLegacyChat =
        settings.containsKey('chat_messages') || legacyScopedKeys.isNotEmpty;
    for (final oldKey in legacyScopedKeys) {
      final raw = settings.get(oldKey);
      final sitterId = oldKey.substring('chat_messages_'.length);
      final threadOwnerId = raw is List
          ? _recognizedScopedThreadOwner(raw, sitterId, settings)
          : null;
      if (raw is List && sitters.containsKey(sitterId) && threadOwnerId != null) {
        await _mergeMessages(
          settings,
          _chatKey(threadOwnerId, sitterId),
          raw,
        );
      }
      await settings.put('legacy_chat_archive_$oldKey', raw);
      await settings.delete(oldKey);
    }
    if (settings.containsKey('chat_messages')) {
      final raw = settings.get('chat_messages');
      final knownMessages = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;
          for (final demo in HiveSeedData.initialChatMessages) {
            final demoMap = demo.toMap();
            if (<String>[
              'id',
              'senderName',
              'text',
              'time',
              'isMe',
            ].every((field) => item[field] == demoMap[field])) {
              knownMessages.add(demoMap);
              break;
            }
          }
        }
      }
      await _mergeMessages(
        settings,
        _chatKey(ConversationIdentity.legacyOwnerId, 'sitter_2'),
        knownMessages,
      );
      // The old global pool has no recipient IDs. Preserve ambiguous rows,
      // but never expose them as another owner's or sitter's conversation.
      await settings.put('legacy_chat_archive_chat_messages', raw);
      await settings.delete('chat_messages');
    }
    final demoKey = _chatKey(ConversationIdentity.legacyOwnerId, 'sitter_2');
    if (!hadLegacyChat && !settings.containsKey(demoKey)) {
      await settings.put(
        demoKey,
        HiveSeedData.initialChatMessages
            .map((message) => message.toMap())
            .toList(),
      );
    }
  }

  static String _normalizeOwnerName(String? name) => (name ?? '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[\s.]+'), ' ')
      .trim();

  static Set<String> _ownerAliases(String normalizedName) => <String>{
    if (normalizedName.isNotEmpty) ...<String>[
      normalizedName,
      normalizedName.split(' ').first,
    ],
  };

  static String? _recognizedScopedThreadOwner(
    List<dynamic> messages,
    String sitterId,
    Box<dynamic> settings,
  ) {
    if (messages.isEmpty) return ConversationIdentity.legacyOwnerId;
    final legacyAliases = _ownerAliases(
      _normalizeOwnerName(AppStrings.defaultOwnerFullName),
    );
    final savedAliases = _ownerAliases(_normalizeOwnerName(
      settings.get('user_name') as String? ?? AppStrings.defaultOwnerFullName,
    ));
    final savedIsLegacy = savedAliases.any(legacyAliases.contains);
    final groups = <String>{};
    for (final item in messages) {
      if (item is! Map) return null;
      final isOwner = item['senderRole'] == UserRole.owner.name ||
          (item['senderRole'] == null && item['isMe'] == true);
      if (!isOwner) continue;
      final sender = _normalizeOwnerName(item['senderName'] as String?);
      if (legacyAliases.contains(sender)) {
        groups.add('legacy');
      } else if (savedAliases.contains(sender)) {
        groups.add(savedIsLegacy ? 'legacy' : 'saved');
      } else {
        return null;
      }
    }
    if (groups.length == 1) {
      return groups.single == 'legacy'
          ? ConversationIdentity.legacyOwnerId
          : settings.get('owner_id') as String? ?? ConversationIdentity.legacyOwnerId;
    }
    if (groups.isNotEmpty || sitterId != 'sitter_2') return null;
    // A sitter-only thread has no owner evidence unless every row is a
    // recognizable message from the original demo conversation.
    final knownDemoOnly = messages.every((item) {
      if (item is! Map) return false;
      return HiveSeedData.initialChatMessages.any((demo) {
        final map = demo.toMap();
        return <String>['id', 'senderName', 'text', 'time', 'isMe'].every(
          (field) => item[field] == map[field],
        );
      });
    });
    return knownDemoOnly ? ConversationIdentity.legacyOwnerId : null;
  }

  static Future<void> _mergeMessages(
    Box<dynamic> settings,
    String key,
    List<dynamic> incoming,
  ) async {
    final existing = settings.get(key) as List? ?? <dynamic>[];
    final merged = List<dynamic>.of(existing);
    final existingIds = existing
        .whereType<Map>()
        .map((item) => item['id'])
        .toSet();
    for (final message in incoming.whereType<Map>()) {
      if (existingIds.add(message['id'])) merged.add(message);
    }
    await settings.put(key, merged);
  }

  static Future<void> _recoverSitterName(
    Box<dynamic> settings,
    Box<dynamic> sitters,
  ) async {
    final savedName = settings.get('sitter_user_name') as String?;
    if (savedName == null || savedName.trim().isEmpty) return;
    final sitterId = settings.get('active_sitter_id') as String? ?? 'sitter_1';
    final raw = sitters.get(sitterId);
    if (raw is! Map || raw['name'] == savedName) return;
    await sitters.put(
      sitterId,
      Map<dynamic, dynamic>.from(raw)..['name'] = savedName,
    );
  }
}
