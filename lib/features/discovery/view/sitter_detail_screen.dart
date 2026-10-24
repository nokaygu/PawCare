import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_date_range_calendar.dart';
import '../../../data/models/models.dart';
import '../../pets/controller/pets_controller.dart';
import '../controller/discovery_controller.dart';
import '../widgets/sitter_detail_sections.dart';

class SitterDetailScreen extends StatefulWidget {
  final SitterListing sitter;
  final DiscoveryController discoveryController;
  final PetsController petsController;
  final VoidCallback onBack;
  final VoidCallback onBookingCompleted;

  const SitterDetailScreen({
    super.key,
    required this.sitter,
    required this.discoveryController,
    required this.petsController,
    required this.onBack,
    required this.onBookingCompleted,
  });

  @override
  State<SitterDetailScreen> createState() => _SitterDetailScreenState();
}

class _SitterDetailScreenState extends State<SitterDetailScreen> {
  final DateTime _initialMonth = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final TextEditingController _careNotesController = TextEditingController(
    text: AppStrings.defaultCareNotes,
  );
  int _activeGalleryIndex = 0;

  @override
  void dispose() {
    _careNotesController.dispose();
    super.dispose();
  }

  int get _selectedUnits {
    if (_rangeStart == null || _rangeEnd == null) return 1;
    final diff = _rangeEnd!.difference(_rangeStart!).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get _subtotal => widget.sitter.pricePerUnit * _selectedUnits;
  double get _serviceFee => 50.0;
  double get _totalPrice => _subtotal + _serviceFee;

  bool get _hasValidRange {
    final start = _rangeStart;
    final end = _rangeEnd;
    return start != null &&
        end != null &&
        widget.discoveryController.isBookingRangeAvailable(
          sitter: widget.sitter,
          startDate: start,
          endDate: end,
        );
  }

  Future<void> _sendBookingRequest() async {
    final start = _rangeStart;
    final end = _rangeEnd;
    if (!_hasValidRange || start == null || end == null) return;
    try {
      await widget.discoveryController.submitBookingRequest(
        sitter: widget.sitter,
        dog: widget.petsController.currentDog,
        startDate: start,
        endDate: end,
        selectedUnits: _selectedUnits,
        totalPrice: _totalPrice,
        careNotes: _careNotesController.text,
      );
    } on ArgumentError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.bookingRangeUnavailableError)),
      );
      return;
    }
    if (!mounted) return;
    await BookingConfirmedDialog.show(
      context,
      sitterName: widget.sitter.name,
      onDone: widget.onBookingCompleted,
    );
  }

  void _updateRange(DateTime? start, DateTime? end) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SitterGalleryHeader(
                galleryPaths: widget.sitter.galleryPaths,
                activeIndex: _activeGalleryIndex,
                onPageChanged: (idx) =>
                    setState(() => _activeGalleryIndex = idx),
                onBack: widget.onBack,
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.paddingLg),
                child: _SitterDetailBody(
                  sitter: widget.sitter,
                  petsController: widget.petsController,
                  initialMonth: _initialMonth,
                  rangeStart: _rangeStart,
                  rangeEnd: _rangeEnd,
                  onRangeChanged: _updateRange,
                  careNotesController: _careNotesController,
                  selectedUnits: _selectedUnits,
                  subtotal: _subtotal,
                  serviceFee: _serviceFee,
                  totalPrice: _totalPrice,
                  onSubmit: _hasValidRange ? _sendBookingRequest : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SitterDetailBody extends StatelessWidget {
  final SitterListing sitter;
  final PetsController petsController;
  final DateTime initialMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final void Function(DateTime? start, DateTime? end) onRangeChanged;
  final TextEditingController careNotesController;
  final int selectedUnits;
  final double subtotal;
  final double serviceFee;
  final double totalPrice;
  final VoidCallback? onSubmit;

  const _SitterDetailBody({
    required this.sitter,
    required this.petsController,
    required this.initialMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onRangeChanged,
    required this.careNotesController,
    required this.selectedUnits,
    required this.subtotal,
    required this.serviceFee,
    required this.totalPrice,
    required this.onSubmit,
  });

  Widget _buildDogSelector() => ValueListenableBuilder<Dog>(
    valueListenable: petsController,
    builder: (context, dog, _) => SitterPetSelectionCard(
      dog: dog,
      allDogs: petsController.allDogs,
      onSelectDog: petsController.selectDog,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SitterMainInfoSection(sitter: sitter),
        const SizedBox(height: AppDimens.p24),
        Divider(color: colors.outlineVariant),
        const SizedBox(height: AppDimens.p18),
        _buildDogSelector(),
        const SizedBox(height: AppDimens.p24),
        _CalendarSelectionSection(
          initialMonth: initialMonth,
          rangeStart: rangeStart,
          rangeEnd: rangeEnd,
          unavailableDates: sitter.unavailableDates,
          onRangeChanged: onRangeChanged,
        ),
        const SizedBox(height: AppDimens.p20),
        _CareNotesInputSection(controller: careNotesController),
        const SizedBox(height: AppDimens.p24),
        SitterPriceSummaryBox(
          sitter: sitter,
          selectedUnits: selectedUnits,
          subtotal: subtotal,
          serviceFee: serviceFee,
          totalPrice: totalPrice,
        ),
        const SizedBox(height: AppDimens.p24),
        _SubmitBookingButton(onSubmit: onSubmit),
        const SizedBox(height: AppDimens.p20),
      ],
    );
  }
}

class _CalendarSelectionSection extends StatelessWidget {
  final DateTime initialMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<DateTime> unavailableDates;
  final void Function(DateTime? start, DateTime? end) onRangeChanged;

  const _CalendarSelectionSection({
    required this.initialMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.unavailableDates,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.dateRangeSelectionTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p8),
        Container(
          padding: const EdgeInsets.all(AppDimens.p12),
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
          child: PawDateRangeCalendar(
            initialMonth: initialMonth,
            rangeStart: rangeStart,
            rangeEnd: rangeEnd,
            unavailableDates: unavailableDates,
            onRangeChanged: onRangeChanged,
          ),
        ),
      ],
    );
  }
}

class _CareNotesInputSection extends StatelessWidget {
  final TextEditingController controller;

  const _CareNotesInputSection({required this.controller});

  OutlineInputBorder _border(
    Color color, {
    double width = AppDimens.borderWidthThin,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    final subtleColor = colors.outlineVariant.withValues(
      alpha: AppDimens.alphaLight,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.specialCareNotesTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p8),
        TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: AppStrings.specialCareNotesHint,
            filled: true,
            fillColor: pawTheme.surfaceContainerLowest,
            border: _border(subtleColor),
            enabledBorder: _border(subtleColor),
            focusedBorder: _border(
              colors.primary,
              width: AppDimens.borderWidthThick,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitBookingButton extends StatelessWidget {
  final VoidCallback? onSubmit;

  const _SubmitBookingButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeightLg,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: AppDimens.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
        ),
        child: Text(
          AppStrings.sendBookingRequestButton,
          style: AppTypography.toBold(
            textTheme.titleMedium!,
            color: colors.onPrimary,
          ),
        ),
      ),
    );
  }
}
