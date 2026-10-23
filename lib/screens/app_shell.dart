import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/paw_bottom_nav.dart';
import 'welcome_screen.dart';
import 'owner_home_screen.dart';
import 'explore_screen.dart';
import 'sitter_detail_screen.dart';
import 'dog_profile_screen.dart';
import 'sitter_dashboard_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _showingWelcome = false;
  SitterListing? _activeDetailSitter;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    // If detail view is open
    Widget currentBody;
    if (_showingWelcome) {
      currentBody = WelcomeScreen(
        onContinue: () => setState(() => _showingWelcome = false),
      );
    } else if (_activeDetailSitter != null) {
      currentBody = SitterDetailScreen(
        sitter: _activeDetailSitter!,
        onBack: () => setState(() => _activeDetailSitter = null),
        onBookingCompleted: () {
          setState(() => _activeDetailSitter = null);
          state.setOwnerNavIndex(3); // Go to Taleplerim tab
        },
      );
    } else if (state.role == UserRole.sitter) {
      currentBody = _buildSitterTab(state.sitterNavIndex);
    } else {
      currentBody = _buildOwnerTab(state.ownerNavIndex);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFECE5),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Demo Top Quick Switcher Bar
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text(
                            'Ekranlar:',
                            style: AppTypography.labelTag.copyWith(
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildQuickButton(
                            '1: Karşılama',
                            _showingWelcome,
                            () => setState(() {
                              _showingWelcome = true;
                              _activeDetailSitter = null;
                            }),
                          ),
                          const SizedBox(width: 6),
                          _buildQuickButton(
                            '2: Keşfet',
                            !_showingWelcome &&
                                _activeDetailSitter == null &&
                                state.role == UserRole.owner &&
                                state.ownerNavIndex == 1,
                            () => setState(() {
                              _showingWelcome = false;
                              _activeDetailSitter = null;
                              state.setRole(UserRole.owner);
                              state.setOwnerNavIndex(1);
                            }),
                          ),
                          const SizedBox(width: 6),
                          _buildQuickButton(
                            '3: Sahip Ana Sayfa',
                            !_showingWelcome &&
                                _activeDetailSitter == null &&
                                state.role == UserRole.owner &&
                                state.ownerNavIndex == 0,
                            () => setState(() {
                              _showingWelcome = false;
                              _activeDetailSitter = null;
                              state.setRole(UserRole.owner);
                              state.setOwnerNavIndex(0);
                            }),
                          ),
                          const SizedBox(width: 6),
                          _buildQuickButton(
                            '4: Detay & Rezervasyon',
                            _activeDetailSitter != null,
                            () => setState(() {
                              _showingWelcome = false;
                              _activeDetailSitter = state.sitters.first;
                            }),
                          ),
                          const SizedBox(width: 6),
                          _buildQuickButton(
                            '5: Köpek Profili',
                            !_showingWelcome &&
                                _activeDetailSitter == null &&
                                state.role == UserRole.owner &&
                                state.ownerNavIndex == 2,
                            () => setState(() {
                              _showingWelcome = false;
                              _activeDetailSitter = null;
                              state.setRole(UserRole.owner);
                              state.setOwnerNavIndex(2);
                            }),
                          ),
                          const SizedBox(width: 6),
                          _buildQuickButton(
                            '6: Hizmet Veren Paneli',
                            !_showingWelcome &&
                                _activeDetailSitter == null &&
                                state.role == UserRole.sitter,
                            () => setState(() {
                              _showingWelcome = false;
                              _activeDetailSitter = null;
                              state.setRole(UserRole.sitter);
                              state.setSitterNavIndex(0);
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Main Screen Body
                Expanded(child: currentBody),
                // Bottom Navigation (shown when not in Welcome or Detail screen)
                if (!_showingWelcome && _activeDetailSitter == null)
                  const PawBottomNav(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerTab(int index) {
    switch (index) {
      case 0:
        return OwnerHomeScreen(
          onSitterSelected: (sitter) {
            setState(() => _activeDetailSitter = sitter);
          },
        );
      case 1:
        return ExploreScreen(
          onSitterSelected: (sitter) {
            setState(() => _activeDetailSitter = sitter);
          },
        );
      case 2:
        return const DogProfileScreen();
      case 3:
        return _buildOwnerBookingsTab();
      case 4:
        return _buildOwnerProfileTab();
      default:
        return OwnerHomeScreen(
          onSitterSelected: (sitter) {
            setState(() => _activeDetailSitter = sitter);
          },
        );
    }
  }

  Widget _buildSitterTab(int index) {
    switch (index) {
      case 0:
        return const SitterDashboardScreen();
      case 1:
        return _buildPlaceholderTab(
          'İlanım & Fiyatlarım',
          'İlan fotoğrafları, gecelik ve saatlik fiyatlandırma ayarları.',
        );
      case 2:
        return _buildPlaceholderTab(
          'Müsaitlik Takvimi',
          'Müsait günler, oda kontenjanları ve tatil tarihleri.',
        );
      case 3:
        return _buildPlaceholderTab(
          'Değerlendirmeler',
          'Köpek sahiplerinin bıraktığı puanlar ve yorumlar.',
        );
      case 4:
        return _buildPlaceholderTab(
          'Hizmet Veren Profili',
          'Kimlik doğrulamaları, sertifikalar ve banka hesap bilgileri.',
        );
      default:
        return const SitterDashboardScreen();
    }
  }

  Widget _buildOwnerBookingsTab() {
    final state = AppStateScope.of(context);
    final bookings = state.bookings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rezervasyon Taleplerim',
                style: AppTypography.headlineScreen,
              ),
              const SizedBox(height: 6),
              Text(
                'Gönderdiğiniz tüm bakım ve otel talepleri',
                style: AppTypography.bodyDefault,
              ),
              const SizedBox(height: 20),
              if (bookings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('Henüz rezervasyon bulunmuyor.'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    Color statusBg;
                    Color statusColor;
                    String statusText;

                    switch (b.status) {
                      case BookingStatus.confirmed:
                        statusBg = AppColors.successContainer;
                        statusColor = AppColors.success;
                        statusText = 'Onaylandı';
                        break;
                      case BookingStatus.pending:
                        statusBg = AppColors.secondaryContainer;
                        statusColor = AppColors.primary;
                        statusText = 'Beklemede';
                        break;
                      case BookingStatus.rejected:
                        statusBg = AppColors.errorContainer;
                        statusColor = AppColors.error;
                        statusText = 'Reddedildi';
                        break;
                      case BookingStatus.completed:
                        statusBg = AppColors.surfaceContainerLow;
                        statusColor = AppColors.onSurfaceVariant;
                        statusText = 'Tamamlandı';
                        break;
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(b.sitterPhoto),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.sitterName,
                                      style: AppTypography.titleCard,
                                    ),
                                    Text(
                                      b.serviceTitle,
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
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  statusText,
                                  style: AppTypography.labelTag.copyWith(
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Toplam Ücret',
                                  style: AppTypography.caption,
                                ),
                                Text(
                                  '₺${b.totalPrice.toInt()}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerProfileTab() {
    final state = AppStateScope.of(context);
    final dog = state.currentDog;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hesap & Profil', style: AppTypography.headlineScreen),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.secondaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aygen Y.',
                            style: AppTypography.headlineSection,
                          ),
                          Text(
                            'aygen@pawcare.com',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Köpek Sahibi (1 Kayıtlı Köpek: ${dog.name})',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Ayarlar & Tercihler', style: AppTypography.headlineSection),
              const SizedBox(height: 12),
              _buildSettingTile(
                Icons.notifications_outlined,
                'Bildirim Tercihleri',
              ),
              const SizedBox(height: 8),
              _buildSettingTile(Icons.credit_card_outlined, 'Ödeme Yöntemleri'),
              const SizedBox(height: 8),
              _buildSettingTile(Icons.security_outlined, 'Gizlilik & Güvenlik'),
              const SizedBox(height: 8),
              _buildSettingTile(Icons.help_outline, 'Yardım & Destek'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _showingWelcome = true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Çıkış Yap / Rol Değiştir',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTypography.bodyMedium)),
          const Icon(
            Icons.chevron_right,
            color: AppColors.onSurfaceVariant,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, String description) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headlineScreen),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.tune, color: AppColors.primary, size: 40),
                    const SizedBox(height: 12),
                    Text(title, style: AppTypography.titleCard),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTypography.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickButton(String title, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          title,
          style: AppTypography.labelTag.copyWith(
            color: isActive ? AppColors.primary : Colors.white,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
