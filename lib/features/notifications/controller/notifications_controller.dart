import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationsController extends ValueNotifier<List<NotificationItem>> {
  final NotificationRepository _repository;

  NotificationsController({NotificationRepository? repository})
    : _repository = repository ?? const NotificationRepository(),
      super(
        (repository ?? const NotificationRepository()).getAllNotifications(),
      );

  int get unreadCount => value.where((item) => !item.isRead).length;

  void refresh() {
    value = _repository.getAllNotifications();
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final item = NotificationItem(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timeLabel: AppStrings.timeNow,
      type: type,
      isRead: false,
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
