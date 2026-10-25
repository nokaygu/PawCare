import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/app/router/app_router.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/theme/theme_controller.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/features/auth/controller/auth_controller.dart';
import 'package:paw_care/features/profile/controller/profile_controller.dart';
import 'package:paw_care/features/profile/widgets/profile_modals.dart';
import 'package:paw_care/features/profile/widgets/profile_sections.dart';
import 'package:paw_care/features/pets/widgets/dog_profile_sections.dart';
import 'package:paw_care/features/provider/widgets/sitter_dashboard_sections.dart';
import 'package:paw_care/features/provider/widgets/sitter_sub_tabs.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);
  test('Profile avatar follows its own sitter listing and new accounts have no borrowed photo', () async {
    final router = AppRouter();
    final theme = ThemeController();
    final auth = AuthController(router: router);
    final profile = ProfileController(router: router, themeController: theme);
    addTearDown(profile.dispose);
    addTearDown(auth.dispose);
    addTearDown(theme.dispose);
    addTearDown(router.dispose);
    await const SettingsRepository().setActiveSitterId('sitter_2');
    await router.setRole(UserRole.sitter);
    expect(profile.activeAvatarPath, 'assets/images/mert.jpg');
    await auth.signUp(
      name: 'Yeni',
      email: 'new@sitter.test',
      password: 'password',
      confirmPassword: 'password',
      role: UserRole.sitter,
    );
    expect(profile.activeAvatarPath, isEmpty);
  });
  testWidgets(
    'Unknown contact has a disabled call action and a real clinic keeps its own phone',
    (tester) async {
      final booking = HiveSeedData.createInitialBookings().first;
      await tester.pumpWidget(
        _host(ActiveGuestCardSection(confirmedBookings: [booking])),
      );
      final call = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.phone_outlined),
      );
      expect(call.onPressed, isNull);
      final dog = HiveSeedData.initialDog.copyWith(
        clinicPhone: '',
        clinicName: 'Başka Klinik',
      );
      await tester.pumpWidget(_host(VetClinicCardSection(dog: dog)));
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      expect(find.textContaining('Dr. Selin'), findsNothing);
    },
  );
  testWidgets('Unverified provider header never borrows verification', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        SitterProfileHeader(
          sitterName: 'Yeni',
          facilityTitle: 'Yeni ilan',
          onSwitchToOwner: () {},
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
      ),
    );
    expect(find.byIcon(Icons.verified), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Reviews are explicitly examples for every account', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: SitterReviewsTab(
          unreadNotifications: 0,
          onNotificationsTap: () {},
        ),
      ),
    );
    expect(find.text(AppStrings.reviewsSummarySubtitle), findsOneWidget);
    expect(AppStrings.reviewsSummarySubtitle, contains('örnektir'));
  });
  testWidgets(
    'Notifications menu opens the named action without claiming preferences',
    (tester) async {
      var opened = false;
      await tester.pumpWidget(
        _host(
          ProfileSettingsList(
            onNotificationsTap: () => opened = true,
            onToggleRole: () {},
            onPaymentTap: () {},
            onPrivacyTap: () {},
            onHelpTap: () {},
          ),
        ),
      );
      expect(find.text('Bildirim Tercihleri'), findsNothing);
      await tester.tap(find.text('Bildirimler'));
      expect(opened, isTrue);
    },
  );
  testWidgets('Payment and help modals explain actual local behavior', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const ProfileInfoModal(
          title: AppStrings.paymentMethodsTitle,
          icon: Icons.credit_card,
          items: AppStrings.paymentModalItems,
        ),
      ),
    );
    expect(
      find.textContaining('kayıtlı kart veya ödeme işlemi yoktur'),
      findsOneWidget,
    );
    expect(find.textContaining('4821'), findsNothing);
    await tester.pumpWidget(
      _host(
        const ProfileInfoModal(
          title: AppStrings.helpAndSupportTitle,
          icon: Icons.help,
          items: AppStrings.helpModalItems,
        ),
      ),
    );
    expect(find.textContaining('henüz başlamamış'), findsOneWidget);
    expect(find.textContaining('24 saat'), findsNothing);
  });
}
