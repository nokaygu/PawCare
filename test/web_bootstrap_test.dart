@TestOn('browser')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/app/app.dart';
import 'package:paw_care/app/bootstrap.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/utils/image_storage_service.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/features/home/view/owner_home_screen.dart';
import 'package:paw_care/features/onboarding/view/welcome_screen.dart';

Iterable<Widget> _widgets(Element element) sync* {
  yield element.widget;
  final children = <Element>[];
  element.visitChildren(children.add);
  for (final child in children) {
    yield* _widgets(child);
  }
}

Future<void> _waitForScreen<T extends Widget>() async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final root = WidgetsBinding.instance.rootElement;
    if (root == null) continue;
    final widgets = _widgets(root).toList();
    if (widgets.whereType<Text>().any(
      (text) => text.data == AppStrings.startupErrorTitle,
    )) {
      throw StateError('Browser showed the records opening error');
    }
    if (widgets.whereType<PawCareApp>().isNotEmpty &&
        widgets.whereType<T>().isNotEmpty) {
      return;
    }
  }
  throw StateError('Browser did not reach $T');
}

Future<void> checkBrowserPhotoMaintenance() async {
  final storage = ImageStorageService(
    documentsDirectory: () => throw StateError('Native directory on web'),
  );
  if (await storage.recoverLostPetPhoto() != null) {
    throw StateError('Browser attempted Android photo recovery');
  }
  await storage.pruneOrphanedPhotos({});
}

Future<void> checkFreshBrowserStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PawCareBootstrap());
  await _waitForScreen<WelcomeScreen>();
}

Future<void> checkExistingBrowserRecords() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SizedBox.shrink());
  await WidgetsBinding.instance.endOfFrame;
  await Hive.close();
  await HiveBoxes.initFlutterAndOpen();
  await const SettingsRepository().setUserRole(UserRole.owner);
  await HiveBoxes.putValue(
    HiveBoxes.settingsBoxName,
    'web_regression_record',
    'preserve existing records',
  );
  await Hive.close();
  runApp(const PawCareBootstrap());
  await _waitForScreen<OwnerHomeScreen>();
  if (HiveBoxes.getValue(HiveBoxes.settingsBoxName, 'web_regression_record') !=
      'preserve existing records') {
    throw StateError('Browser lost an existing IndexedDB record');
  }
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(() async {
    runApp(const SizedBox.shrink());
    await WidgetsBinding.instance.endOfFrame;
    // The runner uses an isolated browser profile/origin for these boxes.
    await Hive.deleteFromDisk();
    HiveBoxes.clearFallbackMemory();
  });
  test(
    'Browser startup photo maintenance never requests a native directory',
    checkBrowserPhotoMaintenance,
  );
  test(
    'A clean Chrome origin opens without a records error',
    checkFreshBrowserStart,
  );
  test(
    'Chrome reopens existing IndexedDB records without clearing them',
    checkExistingBrowserRecords,
  );
}
