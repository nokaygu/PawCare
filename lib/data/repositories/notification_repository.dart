import '../local/hive_boxes.dart';
import '../models/models.dart';
import 'record_order.dart';
import 'settings_repository.dart';

class NotificationArchivePage {
  final List<NotificationItem> items;
  final bool hasMore;
  NotificationArchivePage(List<NotificationItem> items, this.hasMore)
    : items = List.unmodifiable(items);
}

class NotificationRepository {
  const NotificationRepository();

  bool _canRead(NotificationItem item) {
    const settings = SettingsRepository();
    final role = settings.getUserRole();
    final id = role == UserRole.owner
        ? settings.getOwnerId()
        : settings.getActiveSitterId();
    return item.recipientRole == role && item.recipientId == id;
  }

  List<NotificationItem> getAllNotifications() {
    const settings = SettingsRepository();
    final role = settings.getUserRole();
    final id = role == UserRole.owner
        ? settings.getOwnerId()
        : settings.getActiveSitterId();
    final items = HiveBoxes.readRecords<NotificationItem>(
      HiveBoxes.notificationsBoxName,
      where: (raw) =>
          raw['recipientRole'] == role.name && raw['recipientId'] == id,
    ).where(_canRead).toList();
    items.sort((a, b) {
      final byTime = b.createdAt.compareTo(a.createdAt);
      if (byTime != 0) return byTime;
      return compareNewestRecordIds(a.id, b.id);
    });
    return items;
  }

  Future<NotificationArchivePage> readArchive({int offset = 0}) async {
    const settings = SettingsRepository();
    final role = settings.getUserRole();
    final recipient = role == UserRole.owner
        ? settings.getOwnerId()
        : settings.getActiveSitterId();
    final prefix =
        'notification/${Uri.encodeComponent(role.name)}/${Uri.encodeComponent(recipient)}/';
    final keys =
        HiveBoxes.historyKeys(HiveBoxes.archiveBoxName)
            .whereType<String>()
            .where((key) => key.startsWith(prefix))
            .toList()
          ..sort(
            (a, b) => compareNewestRecordIds(
              a.substring(prefix.length),
              b.substring(prefix.length),
            ),
          );
    final items = <NotificationItem>[];
    for (final key in keys.skip(offset).take(50)) {
      final raw = await HiveBoxes.getHistoryValue(
        HiveBoxes.archiveBoxName,
        key,
      );
      if (raw is! Map) continue;
      try {
        final item = NotificationItem.fromMap(raw);
        if (_canRead(item)) items.add(item);
      } catch (_) {
        /* Preserve unreadable archived originals. */
      }
    }
    return NotificationArchivePage(items, keys.length > offset + 50);
  }

  Future<void> addNotification(NotificationItem item) async {
    await HiveBoxes.putValue(
      HiveBoxes.notificationsBoxName,
      item.id,
      item.toMap(),
    );
  }

  Future<void> markAllAsRead() async {
    final items = getAllNotifications();
    await HiveBoxes.putValues(HiveBoxes.notificationsBoxName, {
      for (final item in items)
        if (!item.isRead) item.id: item.copyWith(isRead: true).toMap(),
    });
  }

  Future<void> markAsRead(String id) async {
    final item = HiveBoxes.readRecord<NotificationItem>(
      HiveBoxes.notificationsBoxName,
      id,
    );
    if (item == null) return;
    if (!_canRead(item)) return;
    final updated = item.copyWith(isRead: true);
    await HiveBoxes.putValue(
      HiveBoxes.notificationsBoxName,
      updated.id,
      updated.toMap(),
    );
  }
}
