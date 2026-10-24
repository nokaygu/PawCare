import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../controller/notifications_controller.dart';
import '../widgets/notification_tile.dart';

class NotificationsModal extends StatelessWidget {
  final NotificationsController controller;

  const NotificationsModal({super.key, required this.controller});

  static Future<void> show(
    BuildContext context, {
    required NotificationsController controller,
  }) {
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => NotificationsModal(controller: controller),
    );
  }

  BoxDecoration _dialogDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.modalRadius),
      boxShadow: pawTheme.floatingShadow,
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDimens.modalBlurSigma,
        sigmaY: AppDimens.modalBlurSigma,
      ),
      child: Dialog(
        backgroundColor: pawTheme.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingLg,
          vertical: AppDimens.paddingXl,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppDimens.maxShellWidth,
            maxHeight: AppDimens.chatModalMaxHeight,
          ),
          padding: const EdgeInsets.all(AppDimens.paddingLg),
          decoration: _dialogDecoration(colors, pawTheme),
          child: ValueListenableBuilder<List<NotificationItem>>(
            valueListenable: controller,
            builder: (context, items, _) =>
                _NotificationsContent(items: items, controller: controller),
          ),
        ),
      ),
    );
  }
}

class _NotificationsContent extends StatelessWidget {
  final List<NotificationItem> items;
  final NotificationsController controller;

  const _NotificationsContent({required this.items, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _NotificationsHeader(controller: controller),
        const SizedBox(height: AppDimens.p14),
        Expanded(
          child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p10),
            itemBuilder: (context, index) {
              final item = items[index];
              return NotificationTile(
                item: item,
                onTap: () => controller.markAsRead(item.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  final NotificationsController controller;

  const _NotificationsHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(AppStrings.notifications, style: textTheme.titleLarge),
        ),
        TextButton(
          onPressed: controller.markAllAsRead,
          child: Text(
            AppStrings.markAllRead,
            style: textTheme.labelSmall?.copyWith(color: colors.primary),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            color: colors.onSurfaceVariant,
            size: AppDimens.iconMd,
          ),
          style: IconButton.styleFrom(
            backgroundColor: pawTheme.surfaceContainerLow,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}
