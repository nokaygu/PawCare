import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/models.dart';
import '../state/app_state.dart';

class SitterDetailScreen extends StatefulWidget {
  final SitterListing sitter;
  final VoidCallback onBack;
  final VoidCallback onBookingCompleted;

  const SitterDetailScreen({
    super.key,
    required this.sitter,
    required this.onBack,
    required this.onBookingCompleted,
  });

  @override
  State<SitterDetailScreen> createState() => _SitterDetailScreenState();
}

class _SitterDetailScreenState extends State<SitterDetailScreen> {
  DateTime _focusedDay = DateTime(2026, 10, 24);
  DateTime? _rangeStart = DateTime(2026, 10, 24);
  DateTime? _rangeEnd = DateTime(2026, 10, 26);
  final _careNotesController = TextEditingController(
    text: 'Barley tavuk alerjisine sahip, kendi maması çantada teslim edilecektir.',
  );
  int _activeGalleryIndex = 0;

  @override
  void dispose() {
    _careNotesController.dispose();
    super.dispose();
  }

  int get _selectedUnits {
    if (_rangeStart == null) return 1;
    if (_rangeEnd == null) return 1;
    final diff = _rangeEnd!.difference(_rangeStart!).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get _subtotal => widget.sitter.pricePerUnit * _selectedUnits;
  double get _serviceFee => 50.0;
  double get _totalPrice => _subtotal + _serviceFee;

  void _sendBookingRequest() {
    final state = AppStateScope.of(context);
    final booking = BookingRequest(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      sitterId: widget.sitter.id,
      sitterName: widget.sitter.name,
      sitterPhoto: widget.sitter.imagePath,
      petName: state.currentDog.name,
      petBreed: state.currentDog.breed,
      serviceTitle:
          '${widget.sitter.category} — $_selectedUnits ${widget.sitter.unitLabel} Rezervasyon',
      startDate: _rangeStart ?? DateTime.now(),
      endDate: _rangeEnd ?? DateTime.now().add(const Duration(days: 1)),
      totalPrice: _totalPrice,
      careNotes: _careNotesController.text,
      status: BookingStatus.pending,
    );

    state.addBooking(booking);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text('Talebiniz İletildi!', style: AppTypography.headlineSection),
            const SizedBox(height: 8),
            Text(
              '${widget.sitter.name} talebinizi inceleyip onaylayacaktır. Hizmet Veren paneline geçerek talebi görüntüleyebilirsiniz.',
              style: AppTypography.bodyDefault,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.onBookingCompleted();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Tamam',
                  style: AppTypography.titleCard.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final dog = state.currentDog;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Gallery Carousel with Back Button
              Stack(
                children: [
                  SizedBox(
                    height: 280,
                    width: double.infinity,
                    child: PageView.builder(
                      itemCount: widget.sitter.galleryPaths.length,
                      onPageChanged: (idx) =>
                          setState(() => _activeGalleryIndex = idx),
                      itemBuilder: (context, idx) {
                        return Image.asset(
                          widget.sitter.galleryPaths[idx],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                        ),
                        onPressed: widget.onBack,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_activeGalleryIndex + 1} / ${widget.sitter.galleryPaths.length}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Sitter Info Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.sitter.category,
                            style: AppTypography.labelTag.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Color(0xFFE5A823),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.sitter.rating}',
                          style: AppTypography.titleCard.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          ' (${widget.sitter.reviewsCount} değerlendirme)',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.sitter.facilityTitle,
                      style: AppTypography.headlineHero,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.sitter.name} • ${widget.sitter.location}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(color: AppColors.outlineVariant),
                    const SizedBox(height: 14),
                    Text(
                      'Tesis Hakkında',
                      style: AppTypography.headlineSection,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.sitter.bio, style: AppTypography.bodyDefault),
                    const SizedBox(height: 18),
                    Text(
                      'Tesis Olanakları',
                      style: AppTypography.headlineSection,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.sitter.amenities.map((amenity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.outlineVariant.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(amenity, style: AppTypography.bodyMedium),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.outlineVariant),
                    const SizedBox(height: 18),
                    // Pet Selection
                    Text(
                      'Rezervasyon Yapılacak Köpek',
                      style: AppTypography.headlineSection,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage(dog.photoPath),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dog.name, style: AppTypography.titleCard),
                                Text(
                                  '${dog.breed} • ${dog.ageYears} Yaş • ${dog.weightKg} kg',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Calendar Section
                    Text(
                      'Tarih Aralığı Seçimi',
                      style: AppTypography.headlineSection,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppColors.cardShadow,
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime(2026, 1, 1),
                        lastDay: DateTime(2027, 12, 31),
                        focusedDay: _focusedDay,
                        rangeSelectionMode: RangeSelectionMode.toggledOn,
                        rangeStartDay: _rangeStart,
                        rangeEndDay: _rangeEnd,
                        calendarFormat: CalendarFormat.month,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: AppTypography.titleCard,
                        ),
                        calendarStyle: CalendarStyle(
                          rangeStartDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          rangeEndDecoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          rangeHighlightColor: AppColors.secondaryContainer,
                          todayDecoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            shape: BoxShape.circle,
                          ),
                        ),
                        onRangeSelected: (start, end, focusedDay) {
                          setState(() {
                            _rangeStart = start;
                            _rangeEnd = end;
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Care notes input
                    Text(
                      'Özel Bakım ve Beslenme Notu',
                      style: AppTypography.headlineSection,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _careNotesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Alerjiler, rutinler, ilaçlar veya özel istekler...',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Price Summary Box
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₺${widget.sitter.pricePerUnit.toInt()} x $_selectedUnits ${widget.sitter.unitLabel}',
                                style: AppTypography.bodyDefault,
                              ),
                              Text(
                                '₺${_subtotal.toInt()}',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PawCare Hizmet Bedeli',
                                style: AppTypography.bodyDefault,
                              ),
                              Text(
                                '₺${_serviceFee.toInt()}',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                          const Divider(
                            height: 20,
                            color: AppColors.outlineVariant,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Toplam Tutar',
                                style: AppTypography.headlineSection,
                              ),
                              Text(
                                '₺${_totalPrice.toInt()}',
                                style: AppTypography.headlineHero.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Submit Booking Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _sendBookingRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Rezervasyon Talebi Gönder',
                          style: AppTypography.titleCard.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
