import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import 'unread_notifications_scope.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

class PawHeaderActions extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onNotificationsTap;

  const PawHeaderActions({
    super.key,
    required this.unreadCount,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final count = UnreadNotificationsScope.maybeOf(context);
    if (count != null) {
      return ValueListenableBuilder<int>(
        valueListenable: count,
        builder: (_, value, _) => _NotificationIconButton(
          unreadCount: value,
          onTap: onNotificationsTap,
        ),
      );
    }
    return _NotificationIconButton(
      unreadCount: unreadCount,
      onTap: onNotificationsTap,
    );
  }
}

class _NotificationIconButton extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationIconButton({
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        IconButton(
          onPressed: onTap,
          tooltip: AppStrings.notifications,
          icon: Icon(
            Icons.notifications_outlined,
            color: colors.primary,
            size: AppDimens.iconMd,
          ),
          style: IconButton.styleFrom(
            backgroundColor: pawTheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusButton),
              side: BorderSide(
                color: colors.outlineVariant.withValues(
                  alpha: AppDimens.alphaLight,
                ),
              ),
            ),
          ),
        ),
        if (unreadCount > 0) _UnreadBadgeDot(unreadCount: unreadCount),
      ],
    );
  }
}

class _UnreadBadgeDot extends StatelessWidget {
  final int unreadCount;

  const _UnreadBadgeDot({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Positioned(
      right: AppDimens.p4,
      top: AppDimens.p4,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: AppDimens.badgeMinSize,
          minHeight: AppDimens.badgeMinSize,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
        decoration: BoxDecoration(color: colors.error, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(
          '$unreadCount',
          style: AppTypography.toMicroTag(
            textTheme.labelSmall!,
            color: colors.onError,
          ),
        ),
      ),
    );
  }
}
