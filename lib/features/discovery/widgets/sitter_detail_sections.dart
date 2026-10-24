import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_avatar_image.dart';
import '../../../data/models/models.dart';

class SitterGalleryHeader extends StatelessWidget {
  final List<String> galleryPaths;
  final int activeIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onBack;

  const SitterGalleryHeader({
    super.key,
    required this.galleryPaths,
    required this.activeIndex,
    required this.onPageChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Stack(
      children: <Widget>[
        SizedBox(
          height: AppDimens.detailGalleryHeight,
          width: double.infinity,
          child: PageView.builder(
            itemCount: galleryPaths.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, idx) =>
                PawBoxImage(path: galleryPaths[idx], width: double.infinity),
          ),
        ),
        Positioned(
          top: AppDimens.p16,
          left: AppDimens.p16,
          child: CircleAvatar(
            backgroundColor: pawTheme.glassBadge,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.primary),
              onPressed: onBack,
            ),
          ),
        ),
        Positioned(
          bottom: AppDimens.p16,
          right: AppDimens.p16,
          child: _GalleryPageCounter(
            activeIndex: activeIndex,
            total: galleryPaths.length,
          ),
        ),
      ],
    );
  }
}

class _GalleryPageCounter extends StatelessWidget {
  final int activeIndex;
  final int total;

  const _GalleryPageCounter({required this.activeIndex, required this.total});

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p10,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: pawTheme.galleryBadgeScrim,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Text(
        AppStrings.galleryPosition(activeIndex + 1, total),
        style: textTheme.bodySmall?.copyWith(color: pawTheme.pureWhite),
      ),
    );
  }
}

class SitterMainInfoSection extends StatelessWidget {
  final SitterListing sitter;

  const SitterMainInfoSection({super.key, required this.sitter});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SitterCategoryRatingRow(sitter: sitter),
        const SizedBox(height: AppDimens.p10),
        Text(sitter.facilityTitle, style: textTheme.displayMedium),
        const SizedBox(height: AppDimens.p4),
        Text(
          AppStrings.nameAndLocation(sitter.name, sitter.location),
          style: textTheme.bodyLarge?.copyWith(color: colors.secondary),
        ),
        const SizedBox(height: AppDimens.p18),
        Divider(color: colors.outlineVariant),
        const SizedBox(height: AppDimens.p14),
        Text(AppStrings.aboutFacilityTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p8),
        Text(sitter.bio, style: textTheme.bodyMedium),
        const SizedBox(height: AppDimens.p18),
        Text(AppStrings.facilityAmenitiesTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p10),
        _AmenitiesWrap(amenities: sitter.amenities),
      ],
    );
  }
}

class _SitterCategoryRatingRow extends StatelessWidget {
  final SitterListing sitter;

  const _SitterCategoryRatingRow({required this.sitter});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p10,
            vertical: AppDimens.p4,
          ),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Text(
            sitter.category,
            style: textTheme.labelSmall?.copyWith(color: colors.primary),
          ),
        ),
        const Spacer(),
        Icon(Icons.star, size: AppDimens.iconSm, color: pawTheme.starGold),
        const SizedBox(width: AppDimens.p4),
        Text(
          sitter.rating.toString(),
          style: AppTypography.toBold(textTheme.titleMedium!),
        ),
        Text(
          AppStrings.reviewsCountLabel(sitter.reviewsCount),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AmenitiesWrap extends StatelessWidget {
  final List<String> amenities;

  const _AmenitiesWrap({required this.amenities});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Wrap(
      spacing: AppDimens.p8,
      runSpacing: AppDimens.p8,
      children: amenities.map((amenity) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p12,
            vertical: AppDimens.p8,
          ),
          decoration: BoxDecoration(
            color: pawTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: AppDimens.alphaLight,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.check_circle_outline,
                size: AppDimens.iconXs,
                color: colors.primary,
              ),
              const SizedBox(width: AppDimens.p6),
              Text(amenity, style: textTheme.bodyLarge),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SitterPetSelectionCard extends StatelessWidget {
  final Dog dog;
  final List<Dog> allDogs;
  final ValueChanged<String>? onSelectDog;

  const SitterPetSelectionCard({
    super.key,
    required this.dog,
    this.allDogs = const <Dog>[],
    this.onSelectDog,
  });

  BoxDecoration _itemDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
    bool isSelected,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      border: Border.all(
        color: isSelected
            ? colors.primary
            : colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        width: isSelected
            ? AppDimens.borderWidthThick
            : AppDimens.borderWidthThin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    final dogsToDisplay = allDogs.isEmpty ? <Dog>[dog] : allDogs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.bookingDogSelectionTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p10),
        Column(
          children: dogsToDisplay.map((item) {
            final isSelected = item.id == dog.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.p8),
              child: InkWell(
                onTap: onSelectDog != null ? () => onSelectDog!(item.id) : null,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                child: Container(
                  padding: const EdgeInsets.all(AppDimens.p14),
                  decoration: _itemDecoration(colors, pawTheme, isSelected),
                  child: _PetSelectionRow(dog: item, isSelected: isSelected),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PetSelectionRow extends StatelessWidget {
  final Dog dog;
  final bool isSelected;

  const _PetSelectionRow({required this.dog, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: AppDimens.avatarRadiusSm,
          backgroundImage: PawImageProvider.resolve(dog.photoPath),
        ),
        const SizedBox(width: AppDimens.p12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(dog.name, style: textTheme.titleMedium),
              Text(
                AppStrings.breedAgeWeight(
                  dog.breed,
                  dog.ageYears,
                  dog.weightKg,
                ),
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? colors.primary : colors.outlineVariant,
        ),
      ],
    );
  }
}

class SitterPriceSummaryBox extends StatelessWidget {
  final SitterListing sitter;
  final int selectedUnits;
  final double subtotal;
  final double serviceFee;
  final double totalPrice;

  const SitterPriceSummaryBox({
    super.key,
    required this.sitter,
    required this.selectedUnits,
    required this.subtotal,
    required this.serviceFee,
    required this.totalPrice,
  });

  BoxDecoration _boxDecoration(ColorScheme colors, PawThemeExtension pawTheme) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaLight),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p18),
      decoration: _boxDecoration(colors, pawTheme),
      child: Column(
        children: <Widget>[
          _PriceLineItem(
            label: AppStrings.priceCalculation(
              sitter.pricePerUnit,
              selectedUnits,
              sitter.unitLabel,
            ),
            amount: AppStrings.currencyAmount(subtotal),
          ),
          const SizedBox(height: AppDimens.p8),
          _PriceLineItem(
            label: AppStrings.pawCareServiceFeeLabel,
            amount: AppStrings.currencyAmount(serviceFee),
          ),
          Divider(height: AppDimens.dividerSpace, color: colors.outlineVariant),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(AppStrings.totalAmountLabel, style: textTheme.titleLarge),
              Text(
                AppStrings.currencyAmount(totalPrice),
                style: AppTypography.toExtraBold(
                  textTheme.displayMedium!,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceLineItem extends StatelessWidget {
  final String label;
  final String amount;

  const _PriceLineItem({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: textTheme.bodyMedium),
        Text(amount, style: textTheme.bodyLarge),
      ],
    );
  }
}

class BookingConfirmedDialog extends StatelessWidget {
  final String sitterName;
  final VoidCallback onDone;

  const BookingConfirmedDialog({
    super.key,
    required this.sitterName,
    required this.onDone,
  });

  static Future<void> show(
    BuildContext context, {
    required String sitterName,
    required VoidCallback onDone,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) =>
          BookingConfirmedDialog(sitterName: sitterName, onDone: onDone),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return AlertDialog(
      backgroundColor: pawTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
      ),
      content: _BookingConfirmedDialogBody(
        sitterName: sitterName,
        onDone: onDone,
      ),
    );
  }
}

class _BookingConfirmedDialogBody extends StatelessWidget {
  final String sitterName;
  final VoidCallback onDone;

  const _BookingConfirmedDialogBody({
    required this.sitterName,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppDimens.p16),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: colors.primary,
            size: AppDimens.iconHero,
          ),
        ),
        const SizedBox(height: AppDimens.p18),
        Text(AppStrings.requestSentTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p8),
        Text(
          AppStrings.requestSentBody(sitterName),
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.p24),
        _ConfirmedDoneButton(onDone: onDone),
      ],
    );
  }
}

class _ConfirmedDoneButton extends StatelessWidget {
  final VoidCallback onDone;

  const _ConfirmedDoneButton({required this.onDone});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightMd,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onDone();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
        ),
        child: Text(
          AppStrings.ok,
          style: textTheme.titleMedium?.copyWith(color: colors.onPrimary),
        ),
      ),
    );
  }
}
