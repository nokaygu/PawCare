import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../core/widgets/async_action_builder.dart';
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
            return _OwnerBookingsBody(
              bookings: bookings,
              controller: controller,
              unreadNotifications: unreadNotifications,
              onNotificationsTap: onNotificationsTap,
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
    return CustomScrollView(
      key: const PageStorageKey('owner_bookings_scroll'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppDimens.paddingLg),
          sliver: SliverToBoxAdapter(
            child: _OwnerBookingsTopBar(
              unreadNotifications: unreadNotifications,
              onNotificationsTap: onNotificationsTap,
            ),
          ),
        ),
        _buildHistorySliver(context),
        const SliverToBoxAdapter(child: SizedBox(height: AppDimens.p20)),
      ],
    );
  }

  Widget _buildHistorySliver(BuildContext context) {
    final pawTheme = context.pawTheme;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingLg),
      sliver: bookings.isEmpty
          ? SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppDimens.paddingXl),
                decoration: BoxDecoration(
                  color: pawTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppDimens.cardRadius),
                ),
                child: const Center(child: Text(AppStrings.noBookingsYet)),
              ),
            )
          : SliverList.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p14),
              itemBuilder: (context, index) {
                final item = bookings[index];
                return OwnerBookingCard(
                  booking: item,
                  onCancel:
                      !controller.isBusy && item.canCancelAt(DateTime.now())
                      ? () => performUiAction(
                          context,
                          () => controller.cancelBooking(item),
                          warning: () => controller.lastWarning,
                        )
                      : null,
                );
              },
            ),
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
