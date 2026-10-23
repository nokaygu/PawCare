import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/modals/chat_modal.dart';
import '../widgets/modals/call_modal.dart';

class SitterDashboardScreen extends StatelessWidget {
  const SitterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final bookings = state.bookings;
    final pendingBookings = bookings
        .where((b) => b.status == BookingStatus.pending)
        .toList();
    final confirmedBookings = bookings
        .where((b) => b.status == BookingStatus.confirmed)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sitter Profile Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundImage: AssetImage('assets/images/ayse.jpg'),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ayşe Yılmaz',
                                style: AppTypography.headlineSection,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                          Text(
                            'Mutlu Patiler Köpek Oteli',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => state.setRole(UserRole.owner),
                    icon: const Icon(
                      Icons.swap_horiz,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'Sahip Modu',
                      style: AppTypography.labelTag.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // KPI Metric Cards
              Row(
                children: [
                  _buildMetricCard(
                    'Bekleyen',
                    '${pendingBookings.length}',
                    'Talep',
                    AppColors.secondaryContainer,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _buildMetricCard(
                    'Onaylı',
                    '${confirmedBookings.length}',
                    'Rezervasyon',
                    AppColors.tertiaryFixed,
                    AppColors.tertiary,
                  ),
                  const SizedBox(width: 10),
                  _buildMetricCard(
                    'Kazanç',
                    '₺4.250',
                    'Bu ay',
                    AppColors.surfaceContainerLow,
                    AppColors.onSurface,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Incoming Booking Requests Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Yeni Gelen Talepler',
                    style: AppTypography.headlineSection,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: pendingBookings.isNotEmpty
                          ? AppColors.primary
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${pendingBookings.length}',
                      style: AppTypography.labelTag.copyWith(
                        color: pendingBookings.isNotEmpty
                            ? Colors.white
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (pendingBookings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.task_alt,
                        color: AppColors.success,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tüm talepler yanıtlandı!',
                        style: AppTypography.titleCard,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Şu anda bekleyen yeni rezervasyon talebi bulunmuyor.',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingBookings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final booking = pendingBookings[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: AppColors.cardShadow,
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 22,
                                backgroundImage: AssetImage(
                                  'assets/images/barley.jpg',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${booking.petName} (${booking.petBreed})',
                                      style: AppTypography.titleCard,
                                    ),
                                    Text(
                                      'Sahibi: Aygen • Kadıköy',
                                      style: AppTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '₺${booking.totalPrice.toInt()}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      booking.serviceTitle,
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Not: ${booking.careNotes}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    state.updateBookingStatus(
                                      booking.id,
                                      BookingStatus.rejected,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Talep reddedildi.'),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.error,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Reddet',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    state.updateBookingStatus(
                                      booking.id,
                                      BookingStatus.confirmed,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${booking.petName} için rezervasyon başarıyla onaylandı!',
                                          style: AppTypography.bodyMedium
                                              .copyWith(color: Colors.white),
                                        ),
                                        backgroundColor: AppColors.primary,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.onPrimary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    'Onayla',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () => ChatModal.show(
                                  context,
                                  sitterName: 'Aygen (Köpek Sahibi)',
                                  avatarPath: 'assets/images/barley.jpg',
                                ),
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  'Sahibine Mesaj Gönder',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
              // Active & Upcoming Guests Section
              Text(
                'Aktif & Yaklaşan Konuklar',
                style: AppTypography.headlineSection,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: AppColors.cardShadow,
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/images/barley.jpg'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Barley', style: AppTypography.titleCard),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Giriş Yapıldı',
                                  style: AppTypography.labelTag.copyWith(
                                    color: AppColors.success,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Oda: Süit 3 • 2 Gece Konaklama',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.primary,
                      ),
                      onPressed: () => CallModal.show(
                        context,
                        contactName: 'Aygen (Barley\'nin Sahibi)',
                        roleSubtitle: 'Kayıtlı İletişim Numarası',
                        phoneNumber: '+90 532 890 12 34',
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerLow,
                        shape: const CircleBorder(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppColors.primary,
                      ),
                      onPressed: () => ChatModal.show(
                        context,
                        sitterName: 'Aygen (Köpek Sahibi)',
                        avatarPath: 'assets/images/barley.jpg',
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainerLow,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sitter Tools & Management Links
              Text('Hızlı Yönetim', style: AppTypography.headlineSection),
              const SizedBox(height: 12),
              _buildActionTile(
                Icons.storefront_outlined,
                'İlanımı ve Fiyatlarımı Düzenle',
                'Gecelik ücret, fotoğraflar ve olanaklar',
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                Icons.calendar_month_outlined,
                'Müsaitlik Takvimini Güncelle',
                'Dolu günler ve oda kontenjanları',
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                Icons.star_outline,
                'Değerlendirmelerim & Puanlar',
                '4.9 ortalama puan (128 yorum)',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    Color bgColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.headlineSection.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.caption.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleCard),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
