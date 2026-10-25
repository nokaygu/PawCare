import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/widgets/paw_paged_list.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/sitter_repository.dart';
import 'package:paw_care/features/discovery/controller/discovery_controller.dart';
import 'package:paw_care/features/discovery/view/explore_screen.dart';
import 'package:paw_care/features/discovery/widgets/explore_sitter_card.dart';

class _Catalog extends SitterRepository {
  int reads = 0;
  final List<SitterListing> items;
  _Catalog(this.items);
  @override
  List<SitterListing> getAllSitters() {
    reads++;
    return items;
  }
}

Widget _screen(DiscoveryController controller) => MaterialApp(
  theme: AppTheme.lightTheme,
  home: ExploreScreen(
    controller: controller,
    onSitterSelected: (_) {},
    unreadNotifications: 0,
    onNotificationsTap: () {},
  ),
);

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);
  test('Default discovery includes expensive listings and results are cached immutable snapshots', () {
    final state = DiscoveryFilterState(
      allSitters: [
        HiveSeedData.createInitialSitters().first.copyWith(pricePerUnit: 5000),
      ],
    );
    expect(state.maxPrice, isNull);
    expect(state.filteredSitters, hasLength(1));
    expect(identical(state.filteredSitters, state.filteredSitters), isTrue);
    expect(() => state.filteredSitters.clear(), throwsUnsupportedError);
    expect(state.copyWith(maxPrice: 1500).filteredSitters, isEmpty);
    expect(
      state.copyWith(maxPrice: 1500).copyWith(clearPrice: true).filteredSitters,
      hasLength(1),
    );
  });
  test('Search normalizes Turkish characters, case, and whitespace', () {
    final state = DiscoveryFilterState(
      allSitters: [
        HiveSeedData.createInitialSitters().first.copyWith(
          name: 'IŞIK',
          facilityTitle: 'Şişli Köşk',
          location: 'İSTANBUL',
        ),
      ],
    );
    for (final query in [' isik ', ' SISLI   KOSK ', 'istanbul', 'İstanbul']) {
      expect(
        state.copyWith(searchQuery: query).filteredSitters,
        hasLength(1),
        reason: query,
      );
    }
  });
  testWidgets(
    'Filter cancel discards edits; apply changes once; reset can return to unlimited',
    (tester) async {
      final controller = DiscoveryController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_screen(controller));
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.budgetChipLabel(400)));
      expect(controller.value.maxPrice, isNull);
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(controller.value.maxPrice, isNull);
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.budgetChipLabel(750)));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pump();
      var changes = 0;
      controller.addListener(() => changes++);
      await tester.tap(find.text(AppStrings.apply));
      await tester.pumpAndSettle();
      expect(controller.value.maxPrice, 750);
      expect(controller.value.sortByPriceAsc, isTrue);
      expect(changes, 1);
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.reset));
      await tester.pump();
      expect(controller.value.maxPrice, 750);
      await tester.tap(find.text(AppStrings.apply));
      await tester.pumpAndSettle();
      expect(controller.value.maxPrice, isNull);
      expect(controller.value.sortByPriceAsc, isFalse);
    },
  );
  testWidgets(
    'A thousand listings do not build a thousand cards or reread storage while typing',
    (tester) async {
      final repository = _Catalog(
        List.generate(
          1000,
          (i) => HiveSeedData.createInitialSitters().first.copyWith(id: 's$i'),
        ),
      );
      final controller = DiscoveryController(sitterRepository: repository);
      addTearDown(controller.dispose);
      await tester.pumpWidget(_screen(controller));
      await tester.pumpAndSettle();
      expect(find.byType(ExploreSitterCard).evaluate().length, lessThan(15));
      await tester.enterText(find.byType(TextField), 'Ayşe');
      await tester.pumpAndSettle();
      expect(repository.reads, 1);
      expect(find.byType(ExploreSitterCard).evaluate().length, lessThan(15));
    },
  );
  testWidgets(
    'An embedded history builds only one bounded page and preserves access to later records',
    (tester) async {
      var built = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PawPagedList(
                itemCount: 1000,
                separatorBuilder: (_, _) => const SizedBox(),
                itemBuilder: (_, i) {
                  built++;
                  return Text('record_$i');
                },
              ),
            ),
          ),
        ),
      );
      expect(built, 20);
      expect(find.text('record_20'), findsNothing);
      await tester.ensureVisible(find.byTooltip(AppStrings.nextPage));
      await tester.tap(find.byTooltip(AppStrings.nextPage));
      await tester.pump();
      expect(built, 40);
      expect(find.text('record_20'), findsOneWidget);
      expect(find.text('record_0'), findsNothing);
    },
  );
  testWidgets(
    'An embedded history restores its page after leaving and returning',
    (tester) async {
      final bucket = PageStorageBucket();
      Widget view(bool show) => MaterialApp(
        home: Scaffold(
          body: PageStorage(
            bucket: bucket,
            child: show
                ? SingleChildScrollView(
                    child: PawPagedList(
                      storageId: 'history',
                      itemCount: 100,
                      itemBuilder: (_, i) => Text('row_$i'),
                      separatorBuilder: (_, _) => const SizedBox(),
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      );
      await tester.pumpWidget(view(true));
      await tester.ensureVisible(find.byTooltip(AppStrings.nextPage));
      await tester.tap(find.byTooltip(AppStrings.nextPage));
      await tester.pump();
      expect(find.text('row_20'), findsOneWidget);
      await tester.pumpWidget(view(false));
      await tester.pumpWidget(view(true));
      expect(find.text('row_20'), findsOneWidget);
      expect(find.text('row_0'), findsNothing);
    },
  );
}
