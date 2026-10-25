import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../chat/view/chat_modal.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../core/widgets/paw_status_badge.dart';
import '../../../data/models/models.dart';

class OwnerBookingCard extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback? onCancel;

  const OwnerBookingCard({super.key, required this.booking, this.onCancel});

  BoxDecoration _cardDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      boxShadow: pawTheme.cardShadow,
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p16),
      decoration: _cardDecoration(colors, pawTheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _BookingCardHeader(booking: booking),
          const SizedBox(height: AppDimens.p12),
          _BookingDateRange(booking: booking),
          const SizedBox(height: AppDimens.p10),
          _BookingPriceBar(booking: booking),
          const SizedBox(height: AppDimens.p10),
          _BookingCardActionsRow(booking: booking, onCancel: onCancel),
        ],
      ),
    );
  }
}

class _BookingCardHeader extends StatelessWidget {
  final BookingRequest booking;

  const _BookingCardHeader({required this.booking});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: AppDimens.avatarRadiusSm,
          backgroundImage: PawImageProvider.avatar(
            context,
            booking.sitterPhoto,
            radius: AppDimens.avatarRadiusSm,
          ),
        ),
        const SizedBox(width: AppDimens.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(booking.sitterName, style: textTheme.titleMedium),
              Text(booking.serviceTitle, style: textTheme.bodySmall),
            ],
          ),
        ),
        PawStatusBadge(status: booking.status),
      ],
    );
  }
}

class _BookingDateRange extends StatelessWidget {
  final BookingRequest booking;

  const _BookingDateRange({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.calendar_today_outlined,
          size: AppDimens.iconXxs,
          color: context.colors.secondary,
        ),
        const SizedBox(width: AppDimens.p6),
        Expanded(
          child: Text(
            AppStrings.formatDateRange(booking.startDate, booking.endDate),
            style: context.pawTextTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _BookingPriceBar extends StatelessWidget {
  final BookingRequest booking;

  const _BookingPriceBar({required this.booking});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p10),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              AppStrings.bookingPetAndTotalLabel(booking.petName),
              style: textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          Text(
            AppStrings.currencyAmount(booking.totalPrice),
            style: AppTypography.toExtraBold(
              textTheme.bodyLarge!,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingCardActionsRow extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback? onCancel;

  const _BookingCardActionsRow({required this.booking, this.onCancel});

  Widget _chatButton(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return TextButton.icon(
      onPressed: () => ChatModal.show(
        context,
        ownerId: booking.ownerId,
        sitterId: booking.sitterId,
        sitterName: booking.sitterName,
        avatarPath: booking.sitterPhoto,
      ),
      icon: Icon(
        Icons.chat_bubble_outline,
        size: AppDimens.iconXxs,
        color: colors.primary,
      ),
      label: Text(
        AppStrings.writeToSitterButton,
        style: textTheme.labelSmall?.copyWith(color: colors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: AppDimens.p8,
      children: <Widget>[
        _chatButton(context),
        if (onCancel != null)
          TextButton.icon(
            onPressed: onCancel,
            icon: Icon(
              Icons.cancel_outlined,
              size: AppDimens.iconXxs,
              color: colors.error,
            ),
            label: Text(
              AppStrings.cancelRequestButton,
              style: textTheme.labelSmall?.copyWith(color: colors.error),
            ),
          ),
      ],
    );
  }
}
