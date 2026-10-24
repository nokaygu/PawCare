import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/models.dart';

class NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const NotificationTile({super.key, required this.item, required this.onTap});

  IconData _resolveIcon() {
    return switch (item.type) {
      NotificationType.bookingCreated => Icons.calendar_today_outlined,
      NotificationType.bookingStatusChanged => Icons.verified_outlined,
      NotificationType.vaccineReminder => Icons.vaccines_outlined,
      NotificationType.walkStatus => Icons.directions_walk,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.p14),
        decoration: BoxDecoration(
          color: item.isRead
              ? pawTheme.surfaceContainerLow
              : colors.secondaryContainer.withValues(
                  alpha: AppDimens.alphaSoft,
                ),
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(
            color: item.isRead
                ? colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle)
                : colors.primary.withValues(alpha: AppDimens.alphaLight),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _LeadingIconBadge(icon: _resolveIcon(), isUnread: !item.isRead),
            const SizedBox(width: AppDimens.p12),
            Expanded(
              child: _NotificationBody(item: item, textTheme: textTheme),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadingIconBadge extends StatelessWidget {
  final IconData icon;
  final bool isUnread;

  const _LeadingIconBadge({required this.icon, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p10),
      decoration: BoxDecoration(
        color: isUnread ? colors.primary : colors.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: AppDimens.iconSm,
        color: isUnread ? colors.onPrimary : colors.primary,
      ),
    );
  }
}

class _NotificationBody extends StatelessWidget {
  final NotificationItem item;
  final TextTheme textTheme;

  const _NotificationBody({required this.item, required this.textTheme});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                item.title,
                style: item.isRead
                    ? textTheme.bodyLarge
                    : AppTypography.toBold(textTheme.bodyLarge!),
              ),
            ),
            Text(item.timeLabel, style: textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppDimens.p4),
        Text(
          item.message,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
