import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
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
            return SingleChildScrollView(
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
    final confirmed = state.confirmedBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SitterProfileHeader(
          sitterName: state.sitterDisplayName,
          facilityTitle: state.primarySitter.facilityTitle,
          onSwitchToOwner: controller.switchToOwnerMode,
          unreadNotifications: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
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
        const SizedBox(height: AppDimens.p24),
      ],
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
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    if (pendingBookings.isEmpty) {
      return const EmptyPendingRequestsCard();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingBookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p14),
      itemBuilder: (context, index) {
        final booking = pendingBookings[index];
        return PendingBookingRequestCard(
          booking: booking,
          onReject: () {
            controller.updateBookingStatus(booking, BookingStatus.rejected);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.requestRejectedSnack)),
            );
          },
          onApprove: () {
            controller.updateBookingStatus(booking, BookingStatus.confirmed);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.requestApprovedSnack(booking.petName),
                  style: textTheme.bodyLarge?.copyWith(color: colors.onPrimary),
                ),
                backgroundColor: colors.primary,
              ),
            );
          },
        );
      },
    );
  }
}
