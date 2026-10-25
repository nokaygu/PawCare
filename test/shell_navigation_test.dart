import 'package:paw_care/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/app/router/app_shell.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/theme/theme_controller.dart';
import 'package:paw_care/core/widgets/paw_header_actions.dart';
import 'package:paw_care/core/widgets/unread_notifications_scope.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/discovery/view/explore_screen.dart';
import 'package:paw_care/features/discovery/view/sitter_detail_screen.dart';

class _Reads extends BookingRepository {
  int reads = 0;
  @override
  List<BookingRequest> getAllBookings() {
    reads++;
    return super.getAllBookings();
  }
}

class _SitterReads extends SitterRepository {
  int reads = 0;
  @override
  SitterListing? getById(String id) {
    reads++;
    return super.getById(id);
  }
}

Widget _shell(
  AppRouter router,
  ThemeController theme, {
  BookingRepository? repository,
}) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: AppShell(
    router: router,
    themeController: theme,
    bookingRepository: repository,
  ),
);

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);
  testWidgets(
    'Splash loads no feature history; owner home does not initialize inactive controllers',
    (tester) async {
      final repo = _Reads();
      final router = AppRouter(startWithSplash: true);
      final theme = ThemeController();
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      await tester.pumpWidget(_shell(router, theme, repository: repo));
      expect(repo.reads, 0);
      router.finishSplash();
      await tester.pumpAndSettle();
      expect(repo.reads, 1);
      router.setOwnerNavIndex(1);
      await tester.pumpAndSettle();
      expect(repo.reads, 1);
      router.setOwnerNavIndex(3);
      await tester.pumpAndSettle();
      expect(repo.reads, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('Unread notifications rebuild only their icon subtree', (
    tester,
  ) async {
    final unread = ValueNotifier(0);
    addTearDown(unread.dispose);
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: UnreadNotificationsScope(
          count: unread,
          child: Builder(
            builder: (_) {
              builds++;
              return Scaffold(
                body: PawHeaderActions(
                  unreadCount: 0,
                  onNotificationsTap: () {},
                ),
              );
            },
          ),
        ),
      ),
    );
    expect(builds, 1);
    unread.value = 8;
    await tester.pump();
    expect(find.text('8'), findsOneWidget);
    expect(builds, 1);
  });
  testWidgets(
    'System back closes details, restores exploration scroll, and then returns to home',
    (tester) async {
      const sitters = SitterRepository();
      for (var i = 0; i < 30; i++) {
        await sitters.saveSitter(
          HiveSeedData.createInitialSitters().first.copyWith(id: 'scroll_$i'),
        );
      }
      final router = AppRouter();
      final theme = ThemeController();
      addTearDown(router.dispose);
      addTearDown(theme.dispose);
      router.setOwnerNavIndex(1);
      await tester.pumpWidget(_shell(router, theme));
      await tester.pumpAndSettle();
      final scroll = find.byType(Scrollable).first;
      await tester.drag(scroll, const Offset(0, -850));
      await tester.pumpAndSettle();
      final before = tester.state<ScrollableState>(scroll).position.pixels;
      expect(before, greaterThan(100));
      router.openSitterDetail(sitters.getAllSitters().first);
      await tester.pumpAndSettle();
      expect(find.byType(SitterDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(ExploreScreen), findsOneWidget);
      expect(
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .pixels,
        closeTo(before, 1),
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(router.ownerNavIndex, 0);
      expect(router.canHandleBack, isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets('Provider calendar month survives a tab round trip', (
    tester,
  ) async {
    final router = AppRouter();
    final theme = ThemeController();
    addTearDown(router.dispose);
    addTearDown(theme.dispose);
    await router.setRole(UserRole.sitter);
    router.setSitterNavIndex(2);
    await tester.pumpWidget(_shell(router, theme));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    final next = DateTime(DateTime.now().year, DateTime.now().month + 1);
    final title = '${AppStrings.monthNames[next.month - 1]} ${next.year}';
    expect(find.text(title), findsOneWidget);
    router.setSitterNavIndex(1);
    await tester.pumpAndSettle();
    router.setSitterNavIndex(2);
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  test(
    'Booking snapshots are reused until their box revision changes',
    () async {
      final repo = BookingRepository();
      final before = repo.getAllBookings();
      expect(identical(before, repo.getAllBookings()), isTrue);
      final booking = before.first.copyWith(id: 'new_record');
      await repo.addBooking(booking);
      expect(identical(before, repo.getAllBookings()), isFalse);
      expect(repo.getById('new_record')!.id, 'new_record');
    },
  );
  test('Profile getters reuse their snapshot and refresh only on identity or profile changes', () async {
    final sitters = _SitterReads();
    final router = AppRouter();
    final theme = ThemeController();
    final profile = ProfileController(
      router: router,
      themeController: theme,
      sitterRepository: sitters,
    );
    addTearDown(profile.dispose);
    addTearDown(router.dispose);
    addTearDown(theme.dispose);
    expect(sitters.reads, 1);
    for (var i = 0; i < 100; i++) {
      expect(profile.activeDisplayName, isNotEmpty);
      profile.activeDisplayEmail;
      profile.activeAvatarPath;
    }
    expect(sitters.reads, 1);
    await router.setRole(UserRole.sitter);
    expect(sitters.reads, 2);
    router.setSitterNavIndex(2);
    expect(sitters.reads, 2);
    profile.notifyProfileChanged();
    expect(sitters.reads, 3);
  });
}
