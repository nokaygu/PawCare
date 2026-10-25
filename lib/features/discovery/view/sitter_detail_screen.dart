import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_date_range_calendar.dart';
import '../../../data/models/models.dart';
import '../../../data/models/booking_policy.dart';
import '../../pets/controller/pets_controller.dart';
import '../../pets/widgets/empty_pets_card.dart';
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
    text: '',
  );
  int _activeGalleryIndex = 0;
  int _walkHours = 1;
  TimeOfDay _startTime = TimeOfDay.fromDateTime(
    DateTime.now().add(const Duration(hours: 1)),
  );

  SitterListing get _sitter =>
      widget.discoveryController.value.allSitters
          .where((sitter) => sitter.id == widget.sitter.id)
          .firstOrNull ??
      widget.sitter;
  DateTime? get _serviceStart {
    final start = _rangeStart;
    if (start == null) return null;
    return _sitter.serviceType == ServiceType.walk
        ? DateTime(
            start.year,
            start.month,
            start.day,
            _startTime.hour,
            _startTime.minute,
          )
        : start;
  }

  DateTime? get _serviceEnd => _sitter.serviceType == ServiceType.walk
      ? _serviceStart?.add(Duration(hours: _walkHours))
      : _rangeEnd;
  BookingQuote get _quote {
    final start = _serviceStart;
    final end = _serviceEnd;
    if (start != null && end != null) {
      try {
        return widget.discoveryController.quote(_sitter, start, end);
      } on ArgumentError {
        /* Keep a preview while the range is incomplete. */
      }
    }
    return BookingQuote(
      units: 1,
      unitPriceCents: Money.cents(_sitter.pricePerUnit),
    );
  }

  @override
  void dispose() {
    _careNotesController.dispose();
    super.dispose();
  }

  int get _selectedUnits => _quote.units;
  double get _subtotal => _quote.subtotal;
  double get _serviceFee => _quote.serviceFee;
  double get _totalPrice => _quote.total;

  bool get _hasValidRange {
    final start = _serviceStart;
    final end = _serviceEnd;
    return start != null &&
        end != null &&
        widget.discoveryController.isBookingRangeAvailable(
          sitter: _sitter,
          startDate: start,
          endDate: end,
        );
  }

  Future<void> _sendBookingRequest() async {
    if (!widget.petsController.hasDog) return;
    final start = _serviceStart;
    final end = _serviceEnd;
    if (!_hasValidRange || start == null || end == null) return;
    try {
      await widget.discoveryController.submitBookingRequest(
        sitter: _sitter,
        dog: widget.petsController.currentDog,
        startDate: start,
        endDate: end,
        selectedUnits: _selectedUnits,
        totalPrice: _totalPrice,
        careNotes: _careNotesController.text,
      );
    } on BookingFailure catch (error) {
      if (!mounted) return;
      widget.discoveryController.refreshSitters();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message as String)));
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.bookingSaveFailed)),
      );
      return;
    }
    if (!mounted) return;
    final warning = widget.discoveryController.lastWarning;
    if (warning != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(warning)));
    }
    await BookingConfirmedDialog.show(
      context,
      sitterName: _sitter.name,
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
    return ValueListenableBuilder<DiscoveryFilterState>(
      valueListenable: widget.discoveryController,
      builder: (_, _, _) => _buildContent(context),
    );
  }

  Widget _walkTimeControls(BuildContext context) => Wrap(
    spacing: AppDimens.p12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      OutlinedButton.icon(
        onPressed: widget.discoveryController.isBusy
            ? null
            : () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (mounted && time != null) setState(() => _startTime = time);
              },
        icon: const Icon(Icons.schedule),
        label: Text(AppStrings.startTimeLabel(_startTime.format(context))),
      ),
      DropdownButton<int>(
        value: _walkHours,
        hint: const Text(AppStrings.serviceDuration),
        items: [1, 2, 3, 4]
            .map(
              (hours) => DropdownMenuItem(
                value: hours,
                child: Text(AppStrings.durationHours(hours)),
              ),
            )
            .toList(),
        onChanged: widget.discoveryController.isBusy
            ? null
            : (hours) => setState(() => _walkHours = hours ?? 1),
      ),
    ],
  );

  Widget _buildContent(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SitterGalleryHeader(
                galleryPaths: _sitter.galleryPaths,
                activeIndex: _activeGalleryIndex,
                onPageChanged: (idx) =>
                    setState(() => _activeGalleryIndex = idx),
                onBack: widget.onBack,
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.paddingLg),
                child: _SitterDetailBody(
                  sitter: _sitter,
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
                  onSubmit: _hasValidRange && !widget.discoveryController.isBusy
                      ? _sendBookingRequest
                      : null,
                  timeControls: _sitter.serviceType == ServiceType.walk
                      ? _walkTimeControls(context)
                      : null,
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
  final Widget? timeControls;

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
    this.timeControls,
  });

  Widget _buildDogSelector() => ValueListenableBuilder<Dog?>(
    valueListenable: petsController,
    builder: (context, dog, _) => dog == null
        ? EmptyPetsCard(controller: petsController)
        : SitterPetSelectionCard(
            dog: dog,
            allDogs: petsController.allDogs,
            onSelectDog: (id) =>
                performUiAction(context, () => petsController.selectDog(id)),
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
        _buildServiceCalendar(),
        ?timeControls,
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
        ValueListenableBuilder<Dog?>(
          valueListenable: petsController,
          builder: (_, dog, _) =>
              _SubmitBookingButton(onSubmit: dog == null ? null : onSubmit),
        ),
        const SizedBox(height: AppDimens.p20),
      ],
    );
  }

  Widget _buildServiceCalendar() {
    return _CalendarSelectionSection(
      initialMonth: initialMonth,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      unavailableDates: sitter.unavailableDates,
      onRangeChanged: onRangeChanged,
      serviceType: sitter.serviceType,
    );
  }
}

class _CalendarSelectionSection extends StatelessWidget {
  final DateTime initialMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<DateTime> unavailableDates;
  final void Function(DateTime? start, DateTime? end) onRangeChanged;
  final ServiceType serviceType;

  const _CalendarSelectionSection({
    required this.initialMonth,
    required this.rangeStart,
    required this.rangeEnd,
    required this.unavailableDates,
    required this.onRangeChanged,
    required this.serviceType,
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
            singleDay: serviceType != ServiceType.hotel,
            exclusiveEnd: true,
            minDate: DateTime.now(),
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
