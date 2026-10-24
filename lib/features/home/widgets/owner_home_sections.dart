import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/modals/chat_modal.dart';
import '../../../core/widgets/modals/live_tracking_modal.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../data/models/models.dart';
import '../../pets/controller/pets_controller.dart';
import '../../pets/widgets/dog_form_modals.dart';
import '../../pets/widgets/health_card_modal.dart';

class OwnerHomeTopHeader extends StatelessWidget {
  final String ownerName;
  final String dogName;
  final VoidCallback onSwitchRole;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const OwnerHomeTopHeader({
    super.key,
    required this.ownerName,
    required this.dogName,
    required this.onSwitchRole,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.greetingOwner(ownerName),
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimens.p2),
              Text(
                AppStrings.dogStatusGreat(dogName),
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.p8),
        _SwitchToSitterChip(onTap: onSwitchRole),
        const SizedBox(width: AppDimens.p8),
        PawHeaderActions(
          unreadCount: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _SwitchToSitterChip extends StatelessWidget {
  final VoidCallback onTap;

  const _SwitchToSitterChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p10,
          vertical: AppDimens.p8,
        ),
        decoration: BoxDecoration(
          color: colors.secondaryContainer,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.swap_horiz,
              size: AppDimens.iconXs,
              color: colors.primary,
            ),
            const SizedBox(width: AppDimens.p4),
            Text(
              AppStrings.roleSitter,
              style: textTheme.labelSmall?.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class DogQuickProfileCard extends StatelessWidget {
  final Dog dog;
  final PetsController petsController;

  const DogQuickProfileCard({
    super.key,
    required this.dog,
    required this.petsController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.p16),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadiusLg),
        boxShadow: pawTheme.cardShadow,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        ),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            child: PawBoxImage(
              path: dog.photoPath,
              width: AppDimens.thumbSm,
              height: AppDimens.thumbSm,
            ),
          ),
          const SizedBox(width: AppDimens.p14),
          Expanded(
            child: _DogQuickProfileDetails(
              dog: dog,
              petsController: petsController,
            ),
          ),
        ],
      ),
    );
  }
}

class _DogQuickProfileDetails extends StatelessWidget {
  final Dog dog;
  final PetsController petsController;

  const _DogQuickProfileDetails({
    required this.dog,
    required this.petsController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(dog.name, style: textTheme.titleMedium),
            const SizedBox(width: AppDimens.p6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p6,
                vertical: AppDimens.p2,
              ),
              decoration: BoxDecoration(
                color: colors.secondaryContainer,
                borderRadius: BorderRadius.circular(AppDimens.radiusXs),
              ),
              child: Text(
                AppStrings.ageYearsBadge(dog.ageYears),
                style: AppTypography.toMicroTag(
                  textTheme.labelSmall!,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.p2),
        Text(
          AppStrings.breedAndWeight(dog.breed, dog.weightKg),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimens.p8),
        _DogQuickActionsRow(dog: dog, petsController: petsController),
      ],
    );
  }
}

class _DogQuickActionsRow extends StatelessWidget {
  final Dog dog;
  final PetsController petsController;

  const _DogQuickActionsRow({required this.dog, required this.petsController});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.p8,
      runSpacing: AppDimens.p6,
      children: <Widget>[
        _QuickActionChip(
          label: AppStrings.healthCardChip,
          icon: Icons.medical_services_outlined,
          onTap: () =>
              HealthCardModal.show(context, petsController: petsController),
        ),
        _QuickActionChip(
          label: AppStrings.editProfileChip,
          icon: Icons.edit_outlined,
          onTap: () => EditDogProfileModal.show(
            context,
            dog: dog,
            petsController: petsController,
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _QuickActionChip({required this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p10,
          vertical: AppDimens.p4,
        ),
        decoration: BoxDecoration(
          color: pawTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppDimens.radiusXs),
          border: Border.all(
            color: colors.outlineVariant.withValues(
              alpha: AppDimens.alphaMedium,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: AppDimens.iconXxs, color: colors.primary),
              const SizedBox(width: AppDimens.p4),
            ],
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingVaccineAlertCard extends StatelessWidget {
  final PetsController petsController;

  const UpcomingVaccineAlertCard({super.key, required this.petsController});

  Widget _vaccineCardButton(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return TextButton(
      onPressed: () =>
          HealthCardModal.show(context, petsController: petsController),
      style: TextButton.styleFrom(
        backgroundColor: pawTheme.glassBadge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p12,
          vertical: AppDimens.p6,
        ),
      ),
      child: Text(
        AppStrings.vaccineCardButton,
        style: textTheme.labelSmall?.copyWith(color: colors.tertiary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return ValueListenableBuilder<Dog>(
      valueListenable: petsController,
      builder: (context, dog, _) {
        final upcoming = dog.vaccinations
            .where((v) => v.status == VaccineStatus.upcoming)
            .firstOrNull;
        return Container(
          padding: const EdgeInsets.all(AppDimens.p16),
          decoration: BoxDecoration(
            color: pawTheme.tertiaryFixed,
            borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            border: Border.all(color: pawTheme.accentWarm),
          ),
          child: Row(
            children: <Widget>[
              const _VaccineIconCircle(),
              const SizedBox(width: AppDimens.p14),
              Expanded(
                child: _VaccineAlertInfoColumn(upcomingVaccine: upcoming),
              ),
              _vaccineCardButton(context),
            ],
          ),
        );
      },
    );
  }
}

class _VaccineIconCircle extends StatelessWidget {
  const _VaccineIconCircle();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.vaccines,
        color: pawTheme.pureWhite,
        size: AppDimens.iconLg,
      ),
    );
  }
}

class _VaccineAlertInfoColumn extends StatelessWidget {
  final Vaccination? upcomingVaccine;

  const _VaccineAlertInfoColumn({required this.upcomingVaccine});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    final title = upcomingVaccine != null
        ? AppStrings.vaccineTimeTitle(upcomingVaccine!.title)
        : AppStrings.allVaccinesCompletedTitle;
    final subtitle = upcomingVaccine != null
        ? AppStrings.vaccineAppointmentSubtitle(
            upcomingVaccine!.dueDate,
            upcomingVaccine!.vetName,
          )
        : AppStrings.noUpcomingVaccineSubtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: AppDimens.p8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: AppTypography.toBold(
                textTheme.titleMedium!,
                color: colors.tertiary,
              ),
            ),
            if (upcomingVaccine != null) const _DaysLeftBadge(),
          ],
        ),
        const SizedBox(height: AppDimens.p2),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(color: colors.tertiary),
        ),
      ],
    );
  }
}

class _DaysLeftBadge extends StatelessWidget {
  const _DaysLeftBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p6,
        vertical: AppDimens.p2,
      ),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        AppStrings.statusUpcoming,
        style: AppTypography.toMicroTag(
          textTheme.labelSmall!,
          color: pawTheme.pureWhite,
        ),
      ),
    );
  }
}

class TodaysReservationLiveCard extends StatelessWidget {
  final BookingRequest? activeBooking;
  final VoidCallback onExplore;

  const TodaysReservationLiveCard({
    super.key,
    required this.onExplore,
    this.activeBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                AppStrings.todaysReservationTitle,
                style: context.pawTextTheme.titleLarge,
              ),
            ),
            if (activeBooking != null) const _PulsingReservationBadge(),
          ],
        ),
        const SizedBox(height: AppDimens.p12),
        if (activeBooking case final booking?)
          _TodaysReservationBodyCard(booking: booking)
        else
          _NoActiveReservationCard(onExplore: onExplore),
      ],
    );
  }
}

class _PulsingReservationBadge extends StatefulWidget {
  const _PulsingReservationBadge();

  @override
  State<_PulsingReservationBadge> createState() =>
      _PulsingReservationBadgeState();
}

class _PulsingReservationBadgeState extends State<_PulsingReservationBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const _ActiveReservationBadge(),
    );
  }
}

class _ActiveReservationBadge extends StatelessWidget {
  const _ActiveReservationBadge();

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p8,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: pawTheme.successContainer,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Text(
        AppStrings.activeReservationBadge,
        style: AppTypography.toMicroTag(
          context.pawTextTheme.labelSmall!,
          color: pawTheme.success,
        ),
      ),
    );
  }
}

class _NoActiveReservationCard extends StatelessWidget {
  final VoidCallback onExplore;

  const _NoActiveReservationCard({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p18),
      decoration: _reservationCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.event_available_outlined, color: colors.primary),
          const SizedBox(height: AppDimens.p12),
          Text(
            AppStrings.noActiveReservationTitle,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.p8),
          Text(
            AppStrings.noActiveReservationSubtitle,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimens.p16),
          FilledButton.icon(
            onPressed: onExplore,
            icon: const Icon(Icons.search, size: AppDimens.iconSm),
            label: const Text(AppStrings.exploreSittersButton),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _reservationCardDecoration(BuildContext context) {
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

class _TodaysReservationBodyCard extends StatelessWidget {
  final BookingRequest booking;

  const _TodaysReservationBodyCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.p18),
      decoration: _reservationCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _TodaysWalkerRow(booking: booking),
          const SizedBox(height: AppDimens.p12),
          Text(
            AppStrings.formatDateRange(booking.startDate, booking.endDate),
            style: context.pawTextTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.p16),
          _TodaysReservationButtons(booking: booking),
        ],
      ),
    );
  }
}

class _TodaysWalkerRow extends StatelessWidget {
  final BookingRequest booking;

  const _TodaysWalkerRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: AppDimens.avatarRadiusLg,
          backgroundImage: PawImageProvider.resolve(booking.sitterPhoto),
        ),
        const SizedBox(width: AppDimens.p14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(booking.sitterName, style: textTheme.titleMedium),
              const SizedBox(height: AppDimens.p2),
              Text(
                booking.serviceTitle,
                style: textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodaysReservationButtons extends StatelessWidget {
  final BookingRequest booking;

  const _TodaysReservationButtons({required this.booking});

  ButtonStyle _primaryStyle(ColorScheme colors) => ElevatedButton.styleFrom(
    backgroundColor: colors.primary,
    foregroundColor: colors.onPrimary,
    elevation: AppDimens.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
    ),
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
  );

  ButtonStyle _outlinedStyle(ColorScheme colors) => OutlinedButton.styleFrom(
    side: BorderSide(color: colors.primary, width: AppDimens.borderWidthThick),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
    ),
    padding: const EdgeInsets.symmetric(vertical: AppDimens.p12),
  );

  Widget _chatButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => ChatModal.show(
        context,
        ownerId: booking.ownerId,
        sitterId: booking.sitterId,
        sitterName: booking.sitterName,
        avatarPath: booking.sitterPhoto,
      ),
      icon: Icon(
        Icons.chat_bubble_outline,
        size: AppDimens.iconSm,
        color: context.colors.primary,
      ),
      label: Text(
        AppStrings.chatButton,
        style: context.pawTextTheme.bodyLarge?.copyWith(
          color: context.colors.primary,
        ),
      ),
      style: _outlinedStyle(context.colors),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => LiveTrackingModal.show(context),
            icon: const Icon(Icons.navigation_outlined, size: AppDimens.iconSm),
            label: const Text(AppStrings.liveTrackingButton),
            style: _primaryStyle(context.colors),
          ),
        ),
        const SizedBox(width: AppDimens.p10),
        Expanded(child: _chatButton(context)),
      ],
    );
  }
}

class FeaturedSittersSection extends StatelessWidget {
  final List<SitterListing> sitters;
  final VoidCallback onSeeAll;
  final ValueChanged<SitterListing> onSitterTap;

  const FeaturedSittersSection({
    super.key,
    required this.sitters,
    required this.onSeeAll,
    required this.onSitterTap,
  });

  Widget _buildHeaderRow(ColorScheme colors, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            AppStrings.featuredServicesTitle,
            style: textTheme.titleLarge,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            AppStrings.seeAll,
            style: textTheme.bodyLarge?.copyWith(color: colors.primary),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildHeaderRow(colors, textTheme),
        const SizedBox(height: AppDimens.p10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sitters.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p14),
          itemBuilder: (context, index) {
            final s = sitters[index];
            return _FeaturedSitterCompactCard(
              sitter: s,
              onTap: () => onSitterTap(s),
            );
          },
        ),
      ],
    );
  }
}

class _FeaturedSitterCompactCard extends StatelessWidget {
  final SitterListing sitter;
  final VoidCallback onTap;

  const _FeaturedSitterCompactCard({required this.sitter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.p14),
        decoration: BoxDecoration(
          color: pawTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          boxShadow: pawTheme.cardShadow,
          border: Border.all(
            color: colors.outlineVariant.withValues(
              alpha: AppDimens.alphaSubtle,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: PawBoxImage(
                path: sitter.imagePath,
                width: AppDimens.thumbMd,
                height: AppDimens.thumbMd,
              ),
            ),
            const SizedBox(width: AppDimens.p14),
            Expanded(child: _FeaturedSitterInfoColumn(sitter: sitter)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSitterInfoColumn extends StatelessWidget {
  final SitterListing sitter;

  const _FeaturedSitterInfoColumn({required this.sitter});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                sitter.facilityTitle,
                style: textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.verified, size: AppDimens.iconXs, color: colors.primary),
          ],
        ),
        const SizedBox(height: AppDimens.p2),
        Text(
          AppStrings.nameAndLocation(sitter.name, sitter.location),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppDimens.p6),
        _FeaturedSitterBottomRow(sitter: sitter),
      ],
    );
  }
}

class _FeaturedSitterBottomRow extends StatelessWidget {
  final SitterListing sitter;

  const _FeaturedSitterBottomRow({required this.sitter});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.star, size: AppDimens.iconXxs, color: pawTheme.starGold),
            Text(
              AppStrings.ratingAndReviewCount(
                sitter.rating,
                sitter.reviewsCount,
              ),
              style: textTheme.labelSmall,
            ),
          ],
        ),
        Text(
          AppStrings.pricePerUnitShort(sitter.pricePerUnit, sitter.unitLabel),
          style: AppTypography.toExtraBold(
            textTheme.bodyLarge!,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}
