import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_strings.dart';
import '../../data/local/hive_boxes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/paw_bottom_nav.dart';
import '../../data/models/models.dart';
import '../../data/repositories/booking_repository.dart';
import '../../core/widgets/unread_notifications_scope.dart';
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
  final BookingRepository? bookingRepository;

  const AppShell({
    super.key,
    required this.router,
    required this.themeController,
    this.bookingRepository,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  late final BookingRepository _bookingRepository =
      widget.bookingRepository ?? BookingRepository();
  late final NotificationsController _notificationsController =
      NotificationsController();
  OnboardingController? _onboarding;
  PetsController? _pets;
  BookingsController? _bookings;
  HomeController? _home;
  DiscoveryController? _discovery;
  ProviderController? _provider;
  ProfileController? _profile;
  PageStorageBucket _pageBucket = PageStorageBucket();
  late AppRouteState _previousRouteState;

  OnboardingController get _onboardingController =>
      _onboarding ??= OnboardingController(router: widget.router);
  PetsController get _petsController => _pets ??= PetsController(
    bookingRepository: _bookingRepository,
    notificationsController: _notificationsController,
  );
  HomeController get _homeController => _home ??= HomeController(
    router: widget.router,
    petsController: _petsController,
    bookingRepository: _bookingRepository,
  );
  BookingsController get _bookingsController =>
      _bookings ??= BookingsController(
        bookingRepository: _bookingRepository,
        notificationsController: _notificationsController,
        onBookingsChanged: _syncBookings,
      );
  DiscoveryController get _discoveryController =>
      _discovery ??= DiscoveryController(
        bookingRepository: _bookingRepository,
        notificationsController: _notificationsController,
        onBookingsUpdated: _syncBookings,
      );
  ProviderController get _providerController =>
      _provider ??= ProviderController(
        router: widget.router,
        bookingRepository: _bookingRepository,
        notificationsController: _notificationsController,
        onBookingsChanged: _syncBookings,
        onListingsChanged: _syncListings,
      );
  ProfileController get _profileController => _profile ??= ProfileController(
    router: widget.router,
    themeController: widget.themeController,
    onProfileChanged: _syncProfile,
  );

  void _syncBookings() {
    _bookings?.refresh();
    _provider?.refreshBookings();
    _home?.refreshBookings();
  }

  void _syncListings() {
    _provider?.refreshListing();
    _home?.refreshListings();
    _discovery?.refreshSitters();
  }

  void _syncProfile() {
    _home?.refreshOwner();
    _syncListings();
  }

  void _syncAfterIdentityChange() {
    final previous = _previousRouteState;
    final current = widget.router.value;
    _previousRouteState = current;
    if (previous.role != current.role ||
        previous.sessionRevision != current.sessionRevision ||
        (previous.showingWelcome && !current.showingWelcome)) {
      _pageBucket = PageStorageBucket();
      _pets?.refresh();
      _notificationsController.refresh();
      _bookings?.refresh();
      _provider?.refresh();
      _home?.refreshSitters();
      _discovery?.refreshSitters();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _previousRouteState = widget.router.value;
    widget.router.addListener(_syncAfterIdentityChange);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.router.removeListener(_syncAfterIdentityChange);
    _home?.dispose();
    _pets?.dispose();
    _bookings?.dispose();
    _discovery?.dispose();
    _provider?.dispose();
    _profile?.dispose();
    _onboarding?.dispose();
    _notificationsController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notificationsController.refresh();
      _pets?.refreshTime();
      _home?.refreshTime();
      _provider?.refreshBookings();
    }
  }

  void _openNotifications() =>
      NotificationsModal.show(context, controller: _notificationsController);

  Widget _buildReactiveShell(AppRouteState state) {
    final showNav =
        !state.showingSplash &&
        !state.showingWelcome &&
        state.activeDetailSitter == null;
    final owner = state.role == UserRole.owner;
    return UnreadNotificationsScope(
      count: _notificationsController.unread,
      child: PageStorage(
        bucket: _pageBucket,
        child: PopScope(
          canPop: !widget.router.canHandleBack,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) widget.router.handleBack();
          },
          child: Column(
            children: [
              if (HiveBoxes.issues.isNotEmpty)
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.p12),
                    child: Text(
                      AppStrings.invalidRecordsNotice(HiveBoxes.issues.length),
                    ),
                  ),
                ),
              Expanded(child: _resolveScreen(state)),
              if (showNav)
                PawBottomNav(
                  role: state.role,
                  currentIndex: owner
                      ? state.ownerNavIndex
                      : state.sitterNavIndex,
                  onTabSelected: owner
                      ? widget.router.setOwnerNavIndex
                      : widget.router.setSitterNavIndex,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.pawTheme.shellBackdrop,
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimens.maxShellWidth),
        child: Container(
          decoration: BoxDecoration(
            color: context.pawTheme.background,
            boxShadow: context.pawTheme.shellShadow,
          ),
          child: ValueListenableBuilder<AppRouteState>(
            valueListenable: widget.router,
            builder: (_, state, _) => _buildReactiveShell(state),
          ),
        ),
      ),
    ),
  );

  Widget _resolveScreen(AppRouteState routeState) {
    if (routeState.showingSplash) {
      return SplashScreen(onFinished: widget.router.finishSplash);
    }
    if (routeState.showingWelcome) {
      return WelcomeScreen(
        router: widget.router,
        controller: _onboardingController,
      );
    }
    if (routeState.activeDetailSitter != null) {
      return SitterDetailScreen(
        sitter: routeState.activeDetailSitter!,
        discoveryController: _discoveryController,
        petsController: _petsController,
        onBack: widget.router.closeSitterDetail,
        onBookingCompleted: () => widget.router.setOwnerNavIndex(3),
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
        controller: _discoveryController,
        onSitterSelected: widget.router.openSitterDetail,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      2 => DogProfileScreen(
        petsController: _petsController,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      3 => OwnerBookingsScreen(
        controller: _bookingsController,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      4 => ProfileScreen(
        controller: _profileController,
        petsController: _petsController,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      _ => OwnerHomeScreen(
        homeController: _homeController,
        petsController: _petsController,
        onSitterSelected: widget.router.openSitterDetail,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
    };
  }

  Widget _buildSitterTab(int index) {
    return switch (index) {
      1 => SitterListingTab(
        controller: _providerController,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      2 => SitterCalendarTab(
        controller: _providerController,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      3 => SitterReviewsTab(
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      4 => ProfileScreen(
        controller: _profileController,
        petsController: _petsController,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
      _ => SitterDashboardScreen(
        controller: _providerController,
        unreadNotifications: 0,
        onNotificationsTap: _openNotifications,
      ),
    };
  }
}
