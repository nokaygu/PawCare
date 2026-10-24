import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../data/models/models.dart';
import '../controller/bookings_controller.dart';
import '../widgets/owner_booking_card.dart';

class OwnerBookingsScreen extends StatelessWidget {
  final BookingsController controller;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const OwnerBookingsScreen({
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
        child: ValueListenableBuilder<List<BookingRequest>>(
          valueListenable: controller,
          builder: (context, bookings, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLg,
                vertical: AppDimens.paddingLg,
              ),
              child: _OwnerBookingsBody(
                bookings: bookings,
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

class _OwnerBookingsBody extends StatelessWidget {
  final List<BookingRequest> bookings;
  final BookingsController controller;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _OwnerBookingsBody({
    required this.bookings,
    required this.controller,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _OwnerBookingsTopBar(
          unreadNotifications: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
        const SizedBox(height: AppDimens.p20),
        if (bookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingXl),
            decoration: BoxDecoration(
              color: pawTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppDimens.cardRadius),
            ),
            child: const Center(child: Text(AppStrings.noBookingsYet)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p14),
            itemBuilder: (context, index) {
              final item = bookings[index];
              return OwnerBookingCard(
                booking: item,
                onCancel: item.status == BookingStatus.pending
                    ? () => controller.cancelBooking(item)
                    : null,
              );
            },
          ),
      ],
    );
  }
}

class _OwnerBookingsTopBar extends StatelessWidget {
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _OwnerBookingsTopBar({
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.myBookingRequestsTitle,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimens.p6),
              Text(
                AppStrings.myBookingRequestsSubtitle,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PawHeaderActions(
          unreadCount: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}
