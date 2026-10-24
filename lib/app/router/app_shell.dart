import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/paw_bottom_nav.dart';
import '../../data/models/models.dart';
import '../../features/bookings/controller/bookings_controller.dart';
import '../../features/bookings/view/owner_bookings_screen.dart';
import '../../features/discovery/controller/discovery_controller.dart';
import '../../features/discovery/view/explore_screen.dart';
import '../../features/discovery/view/sitter_detail_screen.dart';
import '../../features/home/controller/home_controller.dart';
import '../../features/home/view/owner_home_screen.dart';
import '../../features/notifications/controller/notifications_controller.dart';
import '../../features/notifications/view/notifications_modal.dart';
import '../../features/onboarding/controller/onboarding_controller.dart';
import '../../features/onboarding/view/welcome_screen.dart';
import '../../features/pets/controller/pets_controller.dart';
import '../../features/pets/view/dog_profile_screen.dart';
import '../../features/profile/controller/profile_controller.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/provider/controller/provider_controller.dart';
import '../../features/provider/view/sitter_dashboard_screen.dart';
import '../../features/provider/widgets/sitter_sub_tabs.dart';
import '../../features/splash/view/splash_screen.dart';
import 'app_router.dart';

class AppShell extends StatefulWidget {
  final AppRouter router;
  final ThemeController themeController;

  const AppShell({
    super.key,
    required this.router,
    required this.themeController,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final NotificationsController _notificationsController;
  late final OnboardingController _onboardingController;
  late final PetsController _petsController;
  late final BookingsController _bookingsController;
  late final HomeController _homeController;
  late final DiscoveryController _discoveryController;
  late final ProviderController _providerController;
  late final ProfileController _profileController;
  late AppRouteState _previousRouteState;

  void _syncAfterIdentityChange() {
    final previous = _previousRouteState;
    final current = widget.router.value;
    _previousRouteState = current;
    if (previous.role != current.role ||
        previous.sessionRevision != current.sessionRevision ||
        (previous.showingWelcome && !current.showingWelcome)) {
      _syncAllListingsAndBookings();
    }
  }

  void _syncAllListingsAndBookings() {
    _bookingsController.refresh();
    _providerController.refresh();
    _homeController.refreshSitters();
    _discoveryController.refreshSitters();
  }

  @override
  void initState() {
    super.initState();
    _notificationsController = NotificationsController();
    _onboardingController = OnboardingController(router: widget.router);
    _petsController = PetsController(
      notificationsController: _notificationsController,
    );
    _homeController = HomeController(router: widget.router);
    _bookingsController = BookingsController(
      notificationsController: _notificationsController,
      onBookingsChanged: _syncAllListingsAndBookings,
    );
    _providerController = ProviderController(
      router: widget.router,
      notificationsController: _notificationsController,
      onBookingsChanged: _syncAllListingsAndBookings,
    );
    _discoveryController = DiscoveryController(
      notificationsController: _notificationsController,
      onBookingsUpdated: _syncAllListingsAndBookings,
    );
    _profileController = ProfileController(
      router: widget.router,
      themeController: widget.themeController,
      onProfileChanged: _syncAllListingsAndBookings,
    );
    _previousRouteState = widget.router.value;
    widget.router.addListener(_syncAfterIdentityChange);
  }

  @override
  void dispose() {
    widget.router.removeListener(_syncAfterIdentityChange);
    _notificationsController.dispose();
    _onboardingController.dispose();
    _petsController.dispose();
    _bookingsController.dispose();
    _homeController.dispose();
    _discoveryController.dispose();
    _providerController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _openNotifications() {
    NotificationsModal.show(context, controller: _notificationsController);
  }

  Widget _buildReactiveShell(BuildContext context, AppRouteState routeState) {
    return ValueListenableBuilder<List<NotificationItem>>(
      valueListenable: _notificationsController,
      builder: (context, _, _) {
        return _ShellActiveBody(
          routeState: routeState,
          router: widget.router,
          onboardingController: _onboardingController,
          homeController: _homeController,
          petsController: _petsController,
          discoveryController: _discoveryController,
          bookingsController: _bookingsController,
          providerController: _providerController,
          profileController: _profileController,
          unreadCount: _notificationsController.unreadCount,
          onOpenNotifications: _openNotifications,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;

    return Scaffold(
      backgroundColor: pawTheme.shellBackdrop,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxShellWidth),
          child: Container(
            decoration: BoxDecoration(
              color: pawTheme.background,
              boxShadow: pawTheme.shellShadow,
            ),
            child: ValueListenableBuilder<AppRouteState>(
              valueListenable: widget.router,
              builder: (context, routeState, _) =>
                  _buildReactiveShell(context, routeState),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellActiveBody extends StatelessWidget {
  final AppRouteState routeState;
  final AppRouter router;
  final OnboardingController onboardingController;
  final HomeController homeController;
  final PetsController petsController;
  final DiscoveryController discoveryController;
  final BookingsController bookingsController;
  final ProviderController providerController;
  final ProfileController profileController;
  final int unreadCount;
  final VoidCallback onOpenNotifications;

  const _ShellActiveBody({
    required this.routeState,
    required this.router,
    required this.onboardingController,
    required this.homeController,
    required this.petsController,
    required this.discoveryController,
    required this.bookingsController,
    required this.providerController,
    required this.profileController,
    required this.unreadCount,
    required this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final showBottomNav =
        !routeState.showingSplash &&
        !routeState.showingWelcome &&
        routeState.activeDetailSitter == null;
    final isOwner = routeState.role == UserRole.owner;
    final currentIndex = isOwner
        ? routeState.ownerNavIndex
        : routeState.sitterNavIndex;

    return Column(
      children: <Widget>[
        Expanded(child: _resolveScreen()),
        if (showBottomNav)
          PawBottomNav(
            role: routeState.role,
            currentIndex: currentIndex,
            onTabSelected: (index) {
              if (isOwner) {
                router.setOwnerNavIndex(index);
              } else {
                router.setSitterNavIndex(index);
              }
            },
          ),
      ],
    );
  }

  Widget _resolveScreen() {
    if (routeState.showingSplash) {
      return SplashScreen(onFinished: router.finishSplash);
    }
    if (routeState.showingWelcome) {
      return WelcomeScreen(router: router, controller: onboardingController);
    }
    if (routeState.activeDetailSitter != null) {
      return SitterDetailScreen(
        sitter: routeState.activeDetailSitter!,
        discoveryController: discoveryController,
        petsController: petsController,
        onBack: router.closeSitterDetail,
        onBookingCompleted: () => router.setOwnerNavIndex(3),
      );
    }
    if (routeState.role == UserRole.sitter) {
      return _buildSitterTab(routeState.sitterNavIndex);
    }
    return _buildOwnerTab(routeState.ownerNavIndex);
  }

  Widget _buildOwnerTab(int index) {
    return switch (index) {
      1 => ExploreScreen(
        controller: discoveryController,
        onSitterSelected: router.openSitterDetail,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      2 => DogProfileScreen(
        petsController: petsController,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      3 => OwnerBookingsScreen(
        controller: bookingsController,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      4 => ProfileScreen(
        controller: profileController,
        petsController: petsController,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      _ => OwnerHomeScreen(
        homeController: homeController,
        petsController: petsController,
        onSitterSelected: router.openSitterDetail,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
    };
  }

  Widget _buildSitterTab(int index) {
    return switch (index) {
      1 => SitterListingTab(
        controller: providerController,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      2 => SitterCalendarTab(
        controller: providerController,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      3 => SitterReviewsTab(
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      4 => ProfileScreen(
        controller: profileController,
        petsController: petsController,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
      _ => SitterDashboardScreen(
        controller: providerController,
        unreadNotifications: unreadCount,
        onNotificationsTap: onOpenNotifications,
      ),
    };
  }
}
