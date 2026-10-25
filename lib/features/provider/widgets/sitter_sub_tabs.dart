import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import 'missing_listing_card.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_date_range_calendar.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../data/models/models.dart';
import '../controller/provider_controller.dart';

class SitterListingTab extends StatelessWidget {
  final ProviderController controller;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const SitterListingTab({
    super.key,
    required this.controller,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: ValueListenableBuilder<ProviderState>(
          valueListenable: controller,
          builder: (context, state, _) {
            if (!state.hasListing) {
              return MissingListingCard(
                onAccounts: controller.router.showWelcome,
              );
            }
            return _buildListingContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildListingContent(BuildContext context, ProviderState state) {
    return SingleChildScrollView(
      key: const PageStorageKey('provider_subtab_scroll'),
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SubTabTopBar(
            title: AppStrings.myListingAndPricesTitle,
            unreadNotifications: unreadNotifications,
            onNotificationsTap: onNotificationsTap,
          ),
          const SizedBox(height: AppDimens.p16),
          _SitterListingDetailCard(
            sitter: state.primarySitter,
            onEditTap: () => _EditSitterListingModal.show(
              context,
              sitter: state.primarySitter,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}

class _SitterListingDetailCard extends StatelessWidget {
  final SitterListing sitter;
  final VoidCallback onEditTap;

  const _SitterListingDetailCard({
    required this.sitter,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(sitter.facilityTitle, style: textTheme.titleLarge),
          const SizedBox(height: AppDimens.p4),
          Text(
            AppStrings.categoryAndLocation(sitter.category, sitter.location),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: AppDimens.p10),
          Text(sitter.bio, style: textTheme.bodyMedium),
          const SizedBox(height: AppDimens.p16),
          Text(
            AppStrings.unitPriceLabel(sitter.pricePerUnit, sitter.unitLabel),
            style: AppTypography.toExtraBold(
              textTheme.titleMedium!,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppDimens.p16),
          _EditListingButton(onTap: onEditTap),
        ],
      ),
    );
  }
}

class _EditListingButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditListingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightMd,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.edit_outlined, size: AppDimens.iconSm),
        label: const Text(AppStrings.editListingAndPriceButton),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: AppDimens.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          ),
        ),
      ),
    );
  }
}

class _EditSitterListingModal extends StatefulWidget {
  final SitterListing sitter;
  final ProviderController controller;

  const _EditSitterListingModal({
    required this.sitter,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required SitterListing sitter,
    required ProviderController controller,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) =>
          _EditSitterListingModal(sitter: sitter, controller: controller),
    );
  }

  @override
  State<_EditSitterListingModal> createState() =>
      _EditSitterListingModalState();
}

class _EditSitterListingModalState extends State<_EditSitterListingModal> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _capacityCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.sitter.facilityTitle);
    _locationCtrl = TextEditingController(text: widget.sitter.location);
    _priceCtrl = TextEditingController(
      text: Money.input(widget.sitter.pricePerUnit),
    );
    _bioCtrl = TextEditingController(text: widget.sitter.bio);
    _capacityCtrl = TextEditingController(
      text: widget.sitter.capacity.toString(),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _priceCtrl.dispose();
    _bioCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = Money.parse(_priceCtrl.text);
    final capacity = int.tryParse(_capacityCtrl.text.trim());
    if (price == null) throw ArgumentError(AppStrings.invalidPrice);
    if (capacity == null) throw ArgumentError(AppStrings.invalidCapacity);
    await widget.controller.updateListingDetails(
      facilityTitle: _titleCtrl.text,
      location: _locationCtrl.text,
      pricePerUnit: price,
      capacity: capacity,
      bio: _bioCtrl.text,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.listingUpdatedSnack)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return AlertDialog(
      backgroundColor: pawTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
      ),
      title: Text(
        AppStrings.editListingModalTitle,
        style: textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        key: const PageStorageKey('provider_subtab_scroll'),
        child: _EditListingFields(
          titleCtrl: _titleCtrl,
          locationCtrl: _locationCtrl,
          priceCtrl: _priceCtrl,
          bioCtrl: _bioCtrl,
          capacityCtrl: _capacityCtrl,
          unitLabel: widget.sitter.unitLabel,
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppStrings.cancel, style: textTheme.bodyLarge),
        ),
        _buildSaveAction(context),
      ],
    );
  }

  Widget _buildSaveAction(BuildContext context) {
    final colors = context.colors;

    return AsyncActionBuilder(
      action: _save,
      builder: (_, onSave, busy) => ElevatedButton(
        onPressed: onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        child: Text(busy ? AppStrings.saving : AppStrings.save),
      ),
    );
  }
}

class _EditListingFields extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController locationCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController bioCtrl;
  final TextEditingController capacityCtrl;
  final String unitLabel;

  const _EditListingFields({
    required this.titleCtrl,
    required this.locationCtrl,
    required this.priceCtrl,
    required this.bioCtrl,
    required this.capacityCtrl,
    required this.unitLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldFacilityTitle,
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: locationCtrl,
          decoration: const InputDecoration(
            labelText: AppStrings.fieldDistrictLocation,
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: AppStrings.fieldUnitPrice(unitLabel),
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        TextField(
          controller: capacityCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: AppStrings.capacityLabel,
          ),
        ),
        const SizedBox(height: AppDimens.p10),
        _buildBioField(),
      ],
    );
  }

  Widget _buildBioField() {
    return TextField(
      controller: bioCtrl,
      maxLines: 3,
      decoration: const InputDecoration(labelText: AppStrings.fieldFacilityBio),
    );
  }
}

class SitterCalendarTab extends StatelessWidget {
  final ProviderController controller;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const SitterCalendarTab({
    super.key,
    required this.controller,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;

    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: ValueListenableBuilder<ProviderState>(
          valueListenable: controller,
          builder: (context, state, _) {
            if (!state.hasListing) {
              return MissingListingCard(
                onAccounts: controller.router.showWelcome,
              );
            }
            return _buildCalendarContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildCalendarContent(BuildContext context, ProviderState state) {
    final textTheme = context.pawTextTheme;

    return SingleChildScrollView(
      key: const PageStorageKey('provider_subtab_scroll'),
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SubTabTopBar(
            title: AppStrings.availabilityCalendarTitle,
            unreadNotifications: unreadNotifications,
            onNotificationsTap: onNotificationsTap,
          ),
          const SizedBox(height: AppDimens.p8),
          Text(
            AppStrings.availabilityCalendarHint,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppDimens.p16),
          _CalendarContainerCard(
            unavailableDates: state.primarySitter.unavailableDates,
            onDayTapped: (date) => performUiAction(
              context,
              () => controller.toggleUnavailableDate(date),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarContainerCard extends StatelessWidget {
  final List<DateTime> unavailableDates;
  final ValueChanged<DateTime> onDayTapped;

  const _CalendarContainerCard({
    required this.unavailableDates,
    required this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p14),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        ),
      ),
      child: PawDateRangeCalendar(
        storageId: 'provider_calendar',
        initialMonth: DateTime.now(),
        unavailableDates: unavailableDates,
        onDayTapped: onDayTapped,
      ),
    );
  }
}

class SitterReviewsTab extends StatelessWidget {
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const SitterReviewsTab({
    super.key,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          key: const PageStorageKey('provider_subtab_scroll'),
          padding: const EdgeInsets.all(AppDimens.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SubTabTopBar(
                title: AppStrings.reviewsTabTitle,
                unreadNotifications: unreadNotifications,
                onNotificationsTap: onNotificationsTap,
              ),
              const SizedBox(height: AppDimens.p16),
              const _ReviewsSummaryCard(),
              const SizedBox(height: AppDimens.p16),
              const _ReviewsListSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewsSummaryCard extends StatelessWidget {
  const _ReviewsSummaryCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.star,
                color: pawTheme.starGold,
                size: AppDimens.iconXl,
              ),
              const SizedBox(width: AppDimens.p6),
              Text(AppStrings.reviewsSummaryScore, style: textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppDimens.p8),
          Text(AppStrings.reviewsSummarySubtitle, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ReviewsListSection extends StatelessWidget {
  const _ReviewsListSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppStrings.sitterReviewsList
          .map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.p12),
              child: _ReviewItemCard(author: r.$1, date: r.$2, comment: r.$3),
            ),
          )
          .toList(),
    );
  }
}

class _ReviewItemCard extends StatelessWidget {
  final String author;
  final String date;
  final String comment;

  const _ReviewItemCard({
    required this.author,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Container(
      padding: const EdgeInsets.all(AppDimens.p16),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaSubtle),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(author, style: textTheme.titleMedium),
              Text(date, style: textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppDimens.p6),
          Text(comment, style: textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SubTabTopBar extends StatelessWidget {
  final String title;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _SubTabTopBar({
    required this.title,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: Text(title, style: textTheme.headlineMedium)),
        PawHeaderActions(
          unreadCount: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}
