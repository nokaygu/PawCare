import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../widgets/missing_listing_card.dart';
import '../../../core/widgets/paw_paged_list.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../data/models/models.dart';
import '../controller/provider_controller.dart';
import '../widgets/sitter_dashboard_sections.dart';

class SitterDashboardScreen extends StatelessWidget {
  final ProviderController controller;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const SitterDashboardScreen({
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
            return SingleChildScrollView(
              key: const PageStorageKey('provider_dashboard_scroll'),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLg,
                vertical: AppDimens.paddingLg,
              ),
              child: _SitterDashboardBody(
                state: state,
                controller: controller,
                unreadNotifications: unreadNotifications,
                onNotificationsTap: onNotificationsTap,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SitterDashboardBody extends StatelessWidget {
  final ProviderState state;
  final ProviderController controller;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _SitterDashboardBody({
    required this.state,
    required this.controller,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pending = state.pendingBookings;
    final confirmed = state.activeAndUpcomingBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildIdentityHeader(context),
        const SizedBox(height: AppDimens.p20),
        SitterKpiMetricsRow(
          pendingCount: pending.length,
          confirmedCount: confirmed.length,
          totalEarnings: state.totalConfirmedEarnings,
        ),
        const SizedBox(height: AppDimens.p24),
        IncomingRequestsHeader(pendingCount: pending.length),
        const SizedBox(height: AppDimens.p12),
        _PendingRequestsListSection(
          pendingBookings: pending,
          controller: controller,
        ),
        const SizedBox(height: AppDimens.p24),
        ActiveGuestCardSection(confirmedBookings: confirmed),
        if (state.awaitingCompletion.isNotEmpty) ...[
          const SizedBox(height: AppDimens.p24),
          _buildAwaitingCompletion(context),
        ],
        const SizedBox(height: AppDimens.p24),
      ],
    );
  }

  Widget _buildIdentityHeader(BuildContext context) {
    return SitterProfileHeader(
      sitterName: state.sitterDisplayName,
      facilityTitle: state.primarySitter.facilityTitle,
      photoPath: state.primarySitter.imagePath,
      isVerified: state.primarySitter.isVerified,
      onSwitchToOwner: () =>
          performUiAction(context, controller.switchToOwnerMode),
      unreadNotifications: unreadNotifications,
      onNotificationsTap: onNotificationsTap,
    );
  }

  Widget _buildAwaitingCompletion(BuildContext context) {
    return ActiveGuestCardSection(
      title: AppStrings.awaitingCompletionTitle,
      confirmedBookings: state.awaitingCompletion,
      onComplete: controller.isBusy
          ? null
          : (booking) => performUiAction(
              context,
              () => controller.updateBookingStatus(
                booking,
                BookingStatus.completed,
              ),
              successMessage: AppStrings.serviceCompleted,
              warning: () => controller.lastWarning,
            ),
    );
  }
}

class _PendingRequestsListSection extends StatelessWidget {
  final List<BookingRequest> pendingBookings;
  final ProviderController controller;

  const _PendingRequestsListSection({
    required this.pendingBookings,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingBookings.isEmpty) {
      return const EmptyPendingRequestsCard();
    }

    return PawPagedList(
      storageId: 'provider_pending',
      itemCount: pendingBookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p14),
      itemBuilder: (context, index) {
        final booking = pendingBookings[index];
        return _buildRequestCard(context, booking);
      },
    );
  }

  Widget _buildRequestCard(BuildContext context, BookingRequest booking) {
    return PendingBookingRequestCard(
      booking: booking,
      onReject: controller.isBusy
          ? null
          : () => performUiAction(
              context,
              () => controller.updateBookingStatus(
                booking,
                BookingStatus.rejected,
              ),
              successMessage: AppStrings.requestRejectedSnack,
              warning: () => controller.lastWarning,
            ),
      onApprove: controller.isBusy
          ? null
          : () => performUiAction(
              context,
              () => controller.updateBookingStatus(
                booking,
                BookingStatus.confirmed,
              ),
              warning: () => controller.lastWarning,
              successMessage: AppStrings.requestApprovedSnack(booking.petName),
            ),
    );
  }
}
