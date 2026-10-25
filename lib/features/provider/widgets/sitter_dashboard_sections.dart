import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/widgets/paw_paged_list.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../chat/view/chat_modal.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../data/models/models.dart';

class SitterProfileHeader extends StatelessWidget {
  final String sitterName;
  final String facilityTitle;
  final String photoPath;
  final bool isVerified;
  final VoidCallback onSwitchToOwner;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const SitterProfileHeader({
    super.key,
    required this.sitterName,
    required this.facilityTitle,
    this.photoPath = '',
    this.isVerified = false,
    required this.onSwitchToOwner,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  Widget _switchRoleButton(ColorScheme colors, TextTheme textTheme) {
    return OutlinedButton.icon(
      onPressed: onSwitchToOwner,
      icon: Icon(
        Icons.swap_horiz,
        size: AppDimens.iconXs,
        color: colors.primary,
      ),
      label: Text(
        AppStrings.roleOwnerMode,
        style: textTheme.labelSmall?.copyWith(color: colors.primary),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: colors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p10,
          vertical: AppDimens.p8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: _SitterAvatarIdentityRow(
            sitterName: sitterName,
            facilityTitle: facilityTitle,
            photoPath: photoPath,
            isVerified: isVerified,
          ),
        ),
        _switchRoleButton(colors, textTheme),
        const SizedBox(width: AppDimens.p8),
        PawHeaderActions(
          unreadCount: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _SitterAvatarIdentityRow extends StatelessWidget {
  final String sitterName;
  final String facilityTitle;
  final String photoPath;
  final bool isVerified;

  const _SitterAvatarIdentityRow({
    required this.sitterName,
    required this.facilityTitle,
    this.photoPath = '',
    this.isVerified = false,
  });

  Widget _nameVerifiedRow(ColorScheme colors, TextTheme textTheme) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Text(
            sitterName,
            style: textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppDimens.p4),
        if (isVerified)
          Icon(Icons.verified, size: AppDimens.iconXs, color: colors.primary),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: AppDimens.avatarRadiusXl,
          backgroundImage: PawImageProvider.avatar(
            context,
            photoPath,
            radius: AppDimens.avatarRadiusXl,
          ),
        ),
        const SizedBox(width: AppDimens.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _nameVerifiedRow(colors, textTheme),
              Text(
                facilityTitle,
                style: textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SitterKpiMetricsRow extends StatelessWidget {
  final int pendingCount;
  final int confirmedCount;
  final double totalEarnings;

  const SitterKpiMetricsRow({
    super.key,
    required this.pendingCount,
    required this.confirmedCount,
    this.totalEarnings = 4250.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Row(
      children: <Widget>[
        _KpiMetricCard(
          title: AppStrings.kpiPendingTitle,
          value: pendingCount.toString(),
          subtitle: AppStrings.kpiPendingSubtitle,
          bgColor: colors.secondaryContainer,
          textColor: colors.primary,
        ),
        const SizedBox(width: AppDimens.p10),
        _KpiMetricCard(
          title: AppStrings.kpiConfirmedTitle,
          value: confirmedCount.toString(),
          subtitle: AppStrings.kpiConfirmedSubtitle,
          bgColor: pawTheme.tertiaryFixed,
          textColor: colors.tertiary,
        ),
        const SizedBox(width: AppDimens.p10),
        _KpiMetricCard(
          title: AppStrings.kpiEarningsTitle,
          value: AppStrings.currencyAmount(totalEarnings),
          subtitle: AppStrings.kpiEarningsSubtitle,
          bgColor: pawTheme.surfaceContainerLow,
          textColor: colors.onSurface,
        ),
      ],
    );
  }
}

class _KpiMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color bgColor;
  final Color textColor;

  const _KpiMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    final titleStyle = textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );
    final valStyle = AppTypography.toExtraBold(
      textTheme.titleLarge!,
      color: textColor,
    );
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.p16,
          horizontal: AppDimens.p12,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: titleStyle),
            const SizedBox(height: AppDimens.p6),
            Text(value, style: valStyle),
            const SizedBox(height: AppDimens.p2),
            Text(subtitle, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class IncomingRequestsHeader extends StatelessWidget {
  final int pendingCount;

  const IncomingRequestsHeader({super.key, required this.pendingCount});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    final hasPending = pendingCount > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(AppStrings.incomingRequestsTitle, style: textTheme.titleLarge),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p8,
            vertical: AppDimens.p2,
          ),
          decoration: BoxDecoration(
            color: hasPending ? colors.primary : pawTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Text(
            pendingCount.toString(),
            style: textTheme.labelSmall?.copyWith(
              color: hasPending ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class EmptyPendingRequestsCard extends StatelessWidget {
  const EmptyPendingRequestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingXl),
      width: double.infinity,
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        ),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.task_alt,
            color: pawTheme.success,
            size: AppDimens.iconHero,
          ),
          const SizedBox(height: AppDimens.p10),
          Text(
            AppStrings.allRequestsAnsweredTitle,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.p4),
          Text(
            AppStrings.noPendingRequestsSubtitle,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class PendingBookingRequestCard extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback? onReject;
  final VoidCallback? onApprove;

  const PendingBookingRequestCard({
    super.key,
    required this.booking,
    required this.onReject,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.p18),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadiusLg),
        boxShadow: pawTheme.cardShadow,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _PendingRequestTopRow(booking: booking),
          const SizedBox(height: AppDimens.p14),
          _PendingRequestNotesBox(booking: booking),
          const SizedBox(height: AppDimens.p16),
          _PendingRequestActionButtons(
            booking: booking,
            onReject: onReject,
            onApprove: onApprove,
          ),
        ],
      ),
    );
  }
}

class _PendingRequestTopRow extends StatelessWidget {
  final BookingRequest booking;

  const _PendingRequestTopRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: AppDimens.avatarRadiusMd,
          backgroundImage: PawImageProvider.avatar(
            context,
            booking.petPhotoPath,
            radius: AppDimens.avatarRadiusMd,
          ),
        ),
        const SizedBox(width: AppDimens.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.dogChipLabel(booking.petName, booking.petBreed),
                style: textTheme.titleMedium,
              ),
              Text(
                AppStrings.ownerAndDistrictLabel(booking.ownerName),
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _PriceTagChip(totalPrice: booking.totalPrice),
      ],
    );
  }
}

class _PriceTagChip extends StatelessWidget {
  final double totalPrice;

  const _PriceTagChip({required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p10,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        AppStrings.currencyAmount(totalPrice),
        style: AppTypography.toExtraBold(
          textTheme.bodyLarge!,
          color: colors.primary,
        ),
      ),
    );
  }
}

class _PendingRequestNotesBox extends StatelessWidget {
  final BookingRequest booking;

  const _PendingRequestNotesBox({required this.booking});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.p12),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.bookingPeriod(
              booking.startDate,
              booking.endDate,
              hourly: booking.serviceType == ServiceType.walk,
              dayCare: booking.serviceType == ServiceType.dayCare,
            ),
            style: textTheme.titleSmall,
          ),
          const SizedBox(height: AppDimens.p6),
          _buildServiceTitle(context),
          const SizedBox(height: AppDimens.p6),
          Text(
            AppStrings.careNotesPrefix(booking.careNotes),
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTitle(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Row(
      children: <Widget>[
        Icon(
          Icons.calendar_month,
          size: AppDimens.iconXs,
          color: colors.primary,
        ),
        const SizedBox(width: AppDimens.p6),
        Expanded(child: Text(booking.serviceTitle, style: textTheme.bodyLarge)),
      ],
    );
  }
}

class _PendingRequestActionButtons extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback? onReject;
  final VoidCallback? onApprove;

  const _PendingRequestActionButtons({
    required this.booking,
    required this.onReject,
    required this.onApprove,
  });

  ButtonStyle _rejectStyle(ColorScheme colors) => OutlinedButton.styleFrom(
    side: BorderSide(color: colors.error),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
    ),
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
  );

  ButtonStyle _approveStyle(ColorScheme colors) => ElevatedButton.styleFrom(
    backgroundColor: colors.primary,
    foregroundColor: colors.onPrimary,
    elevation: AppDimens.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
    ),
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onReject,
                style: _rejectStyle(colors),
                child: Text(
                  AppStrings.rejectButton,
                  style: textTheme.bodyLarge?.copyWith(color: colors.error),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.p12),
            Expanded(
              child: ElevatedButton(
                onPressed: onApprove,
                style: _approveStyle(colors),
                child: Text(
                  AppStrings.approveButton,
                  style: AppTypography.toBold(
                    textTheme.bodyLarge!,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p8),
        _MessageOwnerTextButton(booking: booking),
      ],
    );
  }
}

class _MessageOwnerTextButton extends StatelessWidget {
  final BookingRequest booking;

  const _MessageOwnerTextButton({required this.booking});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return TextButton.icon(
      onPressed: () => ChatModal.show(
        context,
        ownerId: booking.ownerId,
        sitterId: booking.sitterId,
        sitterName: AppStrings.contactWithPet(
          booking.ownerName,
          booking.petName,
        ),
        avatarPath: booking.petPhotoPath,
      ),
      icon: Icon(
        Icons.chat_bubble_outline,
        size: AppDimens.iconXs,
        color: colors.primary,
      ),
      label: Text(
        AppStrings.messageOwnerButton,
        style: textTheme.bodySmall?.copyWith(color: colors.primary),
      ),
    );
  }
}

class ActiveGuestCardSection extends StatelessWidget {
  final List<BookingRequest> confirmedBookings;
  final String title;
  final ValueChanged<BookingRequest>? onComplete;

  const ActiveGuestCardSection({
    super.key,
    this.confirmedBookings = const <BookingRequest>[],
    this.title = AppStrings.activeAndUpcomingGuestsTitle,
    this.onComplete,
  });

  Widget _guestCard(BuildContext context, BookingRequest booking) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.p16),
      decoration: _guestCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActiveGuestRow(booking: booking),
          if (onComplete != null)
            TextButton.icon(
              onPressed: () => onComplete!(booking),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(AppStrings.completeService),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: context.pawTextTheme.titleLarge),
        const SizedBox(height: AppDimens.p12),
        if (confirmedBookings.isEmpty)
          const _EmptyActiveGuestsCard()
        else
          PawPagedList(
            storageId: 'provider_guests_$title',
            itemCount: confirmedBookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p12),
            itemBuilder: (context, index) =>
                _guestCard(context, confirmedBookings[index]),
          ),
      ],
    );
  }
}

BoxDecoration _guestCardDecoration(BuildContext context) {
  return BoxDecoration(
    color: context.pawTheme.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(AppDimens.cardRadiusLg),
    boxShadow: context.pawTheme.cardShadow,
    border: Border.all(
      color: context.colors.outlineVariant.withValues(
        alpha: AppDimens.alphaSubtle,
      ),
    ),
  );
}

class _EmptyActiveGuestsCard extends StatelessWidget {
  const _EmptyActiveGuestsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.p16),
      decoration: _guestCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.pets_outlined, color: context.colors.secondary),
          const SizedBox(height: AppDimens.p12),
          Text(
            AppStrings.noActiveGuestsTitle,
            style: context.pawTextTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.p8),
          Text(
            AppStrings.noActiveGuestsSubtitle,
            style: context.pawTextTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ActiveGuestRow extends StatelessWidget {
  final BookingRequest booking;

  const _ActiveGuestRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: AppDimens.avatarRadiusLg,
          backgroundImage: PawImageProvider.avatar(
            context,
            booking.petPhotoPath,
            radius: AppDimens.avatarRadiusLg,
          ),
        ),
        const SizedBox(width: AppDimens.p14),
        Expanded(child: _ActiveGuestInfo(booking: booking)),
        _ActiveGuestActionIcons(booking: booking),
      ],
    );
  }
}

class _ActiveGuestInfo extends StatelessWidget {
  final BookingRequest booking;

  const _ActiveGuestInfo({required this.booking});

  Widget _confirmedBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p6,
        vertical: AppDimens.p2,
      ),
      decoration: BoxDecoration(
        color: context.pawTheme.successContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        AppStrings.statusConfirmed,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.toMicroTag(
          context.pawTextTheme.labelSmall!,
          color: context.pawTheme.success,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(booking.petName, style: textTheme.titleMedium),
        const SizedBox(height: AppDimens.p2),
        _confirmedBadge(context),
        const SizedBox(height: AppDimens.p4),
        Text(
          booking.serviceTitle,
          style: textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          AppStrings.formatDateRange(booking.startDate, booking.endDate),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ActiveGuestActionIcons extends StatelessWidget {
  final BookingRequest booking;

  const _ActiveGuestActionIcons({required this.booking});

  Widget _callButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.phone_outlined, color: context.colors.primary),
      tooltip: AppStrings.phoneNotProvided,
      onPressed: null,
      style: IconButton.styleFrom(
        backgroundColor: context.pawTheme.surfaceContainerLow,
        shape: const CircleBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _callButton(context),
        const SizedBox(width: AppDimens.p6),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: context.colors.primary),
          onPressed: () => ChatModal.show(
            context,
            ownerId: booking.ownerId,
            sitterId: booking.sitterId,
            sitterName: AppStrings.contactWithPet(
              booking.ownerName,
              booking.petName,
            ),
            avatarPath: booking.petPhotoPath,
          ),
          style: IconButton.styleFrom(
            backgroundColor: context.pawTheme.surfaceContainerLow,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}
