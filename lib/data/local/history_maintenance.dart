import 'package:hive/hive.dart';

/// Read notifications older than 90 days leave active storage; originals stay
/// available in the recipient's paged archive. Unread/undated records stay active.
abstract final class HistoryMaintenance {
  static Future<void> archiveReadNotifications({
    required Box<dynamic> active,
    required LazyBox<dynamic> archive,
    DateTime? now,
  }) async {
    final cutoff = (now ?? DateTime.now())
        .subtract(const Duration(days: 90))
        .millisecondsSinceEpoch;
    final copy = <String, dynamic>{};
    final remove = <dynamic>[];
    var moved = false;
    Future<void> flush() async {
      if (copy.isEmpty) return;
      await archive.putAll(copy);
      await active.deleteAll(remove);
      copy.clear();
      remove.clear();
      moved = true;
    }

    for (final key in active.keys.toList()) {
      final raw = active.get(key);
      if (raw is! Map ||
          raw['isRead'] != true ||
          raw['createdAt'] is! int ||
          (raw['createdAt'] as int) >= cutoff ||
          raw['recipientId'] is! String ||
          raw['recipientRole'] is! String) {
        continue;
      }
      final role = Uri.encodeComponent(raw['recipientRole'] as String);
      final recipient = Uri.encodeComponent(raw['recipientId'] as String);
      copy['notification/$role/$recipient/$key'] = raw;
      remove.add(key);
      if (copy.length == 200) await flush();
    }
    await flush();
    if (moved) await active.compact();
  }
}
