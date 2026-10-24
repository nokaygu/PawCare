import '../local/hive_boxes.dart';
import '../models/models.dart';
import 'record_order.dart';

class NotificationRepository {
  const NotificationRepository();

  List<NotificationItem> getAllNotifications() {
    final rawList = HiveBoxes.getValues(HiveBoxes.notificationsBoxName);
    final items = rawList
        .map(
          (e) => NotificationItem.fromMap(Map<dynamic, dynamic>.from(e as Map)),
        )
        .toList();
    items.sort((a, b) => compareNewestRecordIds(a.id, b.id));
    return items;
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
    for (final item in items) {
      if (!item.isRead) {
        final updated = item.copyWith(isRead: true);
        await HiveBoxes.putValue(
          HiveBoxes.notificationsBoxName,
          updated.id,
          updated.toMap(),
        );
      }
    }
  }

  Future<void> markAsRead(String id) async {
    final items = getAllNotifications();
    final idx = items.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final updated = items[idx].copyWith(isRead: true);
    await HiveBoxes.putValue(
      HiveBoxes.notificationsBoxName,
      updated.id,
      updated.toMap(),
    );
  }
}
