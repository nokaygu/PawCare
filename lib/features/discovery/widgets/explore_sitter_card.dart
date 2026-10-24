import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../data/models/models.dart';

class ExploreSitterCard extends StatelessWidget {
  final SitterListing sitter;
  final VoidCallback onInspectTap;

  const ExploreSitterCard({
    super.key,
    required this.sitter,
    required this.onInspectTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Container(
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
        boxShadow: pawTheme.cardShadow,
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ExploreCardImageHeader(sitter: sitter),
          _ExploreCardBody(sitter: sitter, onInspectTap: onInspectTap),
        ],
      ),
    );
  }
}

class _ExploreCardImageHeader extends StatelessWidget {
  final SitterListing sitter;

  const _ExploreCardImageHeader({required this.sitter});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PawBoxImage(
          path: sitter.imagePath,
          height: AppDimens.exploreCardImageHeight,
          width: double.infinity,
        ),
        Positioned(
          top: AppDimens.p12,
          left: AppDimens.p12,
          child: _CategoryGlassChip(category: sitter.category),
        ),
        Positioned(
          top: AppDimens.p12,
          right: AppDimens.p12,
          child: _RatingGlassChip(sitter: sitter),
        ),
      ],
    );
  }
}

class _CategoryGlassChip extends StatelessWidget {
  final String category;

  const _CategoryGlassChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p10,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: pawTheme.glassBadge,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Text(
        category,
        style: textTheme.labelSmall?.copyWith(color: colors.primary),
      ),
    );
  }
}

class _RatingGlassChip extends StatelessWidget {
  final SitterListing sitter;

  const _RatingGlassChip({required this.sitter});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p8,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: pawTheme.glassBadge,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.star, size: AppDimens.iconXxs, color: pawTheme.starGold),
          const SizedBox(width: AppDimens.p4),
          Text(
            AppStrings.ratingAndReviewCount(sitter.rating, sitter.reviewsCount),
            style: textTheme.labelSmall?.copyWith(color: colors.onSurface),
          ),
        ],
      ),
    );
  }
}

class _ExploreCardBody extends StatelessWidget {
  final SitterListing sitter;
  final VoidCallback onInspectTap;

  const _ExploreCardBody({required this.sitter, required this.onInspectTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Padding(
      padding: const EdgeInsets.all(AppDimens.p18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ExploreCardTitleRow(sitter: sitter),
          const SizedBox(height: AppDimens.p12),
          Text(
            sitter.bio,
            style: textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimens.p12),
          _ExploreAmenitiesRow(amenities: sitter.amenities),
          const SizedBox(height: AppDimens.p16),
          _InspectActionButton(onInspectTap: onInspectTap),
        ],
      ),
    );
  }
}

class _ExploreAmenitiesRow extends StatelessWidget {
  final List<String> amenities;

  const _ExploreAmenitiesRow({required this.amenities});

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Wrap(
      spacing: AppDimens.p6,
      runSpacing: AppDimens.p6,
      children: amenities.take(3).map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p8,
            vertical: AppDimens.p4,
          ),
          decoration: BoxDecoration(
            color: pawTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppDimens.radiusXs),
          ),
          child: Text(amenity, style: textTheme.bodySmall),
        );
      }).toList(),
    );
  }
}

class _InspectActionButton extends StatelessWidget {
  final VoidCallback onInspectTap;

  const _InspectActionButton({required this.onInspectTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightMd,
      child: ElevatedButton(
        onPressed: onInspectTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: AppDimens.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppStrings.inspectAndRequestButton,
              style: AppTypography.toBold(
                textTheme.bodyLarge!,
                color: colors.onPrimary,
              ),
            ),
            const SizedBox(width: AppDimens.p8),
            Icon(
              Icons.arrow_forward,
              size: AppDimens.iconXs,
              color: colors.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCardTitleRow extends StatelessWidget {
  final SitterListing sitter;

  const _ExploreCardTitleRow({required this.sitter});

  Widget _priceColumn(ColorScheme colors, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          AppStrings.currencyAmount(sitter.pricePerUnit),
          style: AppTypography.toExtraBold(
            textTheme.titleLarge!,
            color: colors.primary,
          ),
        ),
        Text(
          AppStrings.unitSuffix(sitter.unitLabel),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(sitter.facilityTitle, style: textTheme.titleLarge),
              const SizedBox(height: AppDimens.p2),
              Text(
                AppStrings.sitterNameLocationDistance(
                  sitter.name,
                  sitter.location,
                  sitter.distanceKm,
                ),
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        _priceColumn(colors, textTheme),
      ],
    );
  }
}
