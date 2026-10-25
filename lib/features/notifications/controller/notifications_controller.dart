import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/lifecycle_notifier.dart';
import '../../../core/utils/record_id.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/settings_repository.dart';

class NotificationsController
    extends LifecycleNotifier<List<NotificationItem>> {
  final NotificationRepository _repository;
  bool showingArchive = false;
  int archiveOffset = 0;
  bool archiveHasMore = false;
  final ValueNotifier<int> unread = ValueNotifier(0);

  NotificationsController({NotificationRepository? repository})
    : _repository = repository ?? const NotificationRepository(),
      super(
        (repository ?? const NotificationRepository()).getAllNotifications(),
      ) {
    unread.value = value.where((item) => !item.isRead).length;
  }

  @override
  set value(List<NotificationItem> items) {
    if (isDisposed) return;
    super.value = List.unmodifiable(items);
    if (!showingArchive) {
      unread.value = items.where((item) => !item.isRead).length;
    }
  }

  @override
  void dispose() {
    if (isDisposed) return;
    unread.dispose();
    super.dispose();
  }

  int get unreadCount => unread.value;

  void refresh() {
    showingArchive = false;
    value = _repository.getAllNotifications();
  }

  String get _scope {
    const settings = SettingsRepository();
    final role = settings.getUserRole();
    return '${role.name}/${role == UserRole.owner ? settings.getOwnerId() : settings.getActiveSitterId()}';
  }

  Future<void> showArchived({int offset = 0}) => runExclusive(() async {
    final scope = _scope;
    final page = await _repository.readArchive(offset: offset);
    if (isDisposed) return;
    if (_scope != scope) {
      refresh();
      return;
    }
    showingArchive = true;
    archiveOffset = offset;
    archiveHasMore = page.hasMore;
    value = page.items;
  });

  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
    String? recipientId,
    UserRole? recipientRole,
    String? relatedRecordId,
  }) async {
    const settings = SettingsRepository();
    final role = recipientRole ?? settings.getUserRole();
    final item = NotificationItem(
      id: RecordId.create('notif'),
      title: title,
      message: message,
      timeLabel: AppStrings.timeNow,
      type: type,
      isRead: false,
      recipientRole: role,
      recipientId:
          recipientId ??
          (role == UserRole.owner
              ? settings.getOwnerId()
              : settings.getActiveSitterId()),
      relatedRecordId: relatedRecordId,
      createdAt: DateTime.now(),
    );
    await _repository.addNotification(item);
    refresh();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    refresh();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    refresh();
  }
}
