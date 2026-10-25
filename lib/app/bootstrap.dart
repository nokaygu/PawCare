import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_theme.dart';
import '../data/local/hive_boxes.dart';
import '../core/utils/image_storage_service.dart';
import '../data/repositories/pet_photo_recovery.dart';
import '../features/splash/view/splash_screen.dart';
import 'app.dart';

class PawCareBootstrap extends StatefulWidget {
  final Future<void> Function()? initialize;
  const PawCareBootstrap({super.key, this.initialize});
  @override
  State<PawCareBootstrap> createState() => _PawCareBootstrapState();
}

class _PawCareBootstrapState extends State<PawCareBootstrap> {
  late Future<void> _opening;
  AppLifecycleListener? _resumeListener;
  Completer<void>? _resumed;

  Future<void> _waitForResume() async {
    final state = WidgetsBinding.instance.lifecycleState;
    if (state == null || state == AppLifecycleState.resumed) return;
    final resumed = _resumed = Completer<void>();
    _resumeListener = AppLifecycleListener(
      onResume: () {
        if (!resumed.isCompleted) resumed.complete();
      },
    );
    try {
      await resumed.future;
    } finally {
      _resumeListener?.dispose();
      _resumeListener = null;
      _resumed = null;
    }
  }

  Future<void> _initialize() async {
    if (widget.initialize != null) {
      await widget.initialize!();
      return;
    }
    await HiveBoxes.initFlutterAndOpen();
    final storage = ImageStorageService();
    if (HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          PetPhotoRecovery.pendingKey,
        ) !=
        null) {
      // A translucent Android picker can recreate us before returning its result.
      await _waitForResume();
      if (!mounted) return;
    }
    await PetPhotoRecovery(storage: storage).restore(
      emptyResultRetries:
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? 50 : 0,
    );
    // Maintenance never delays first paint or deletes recent picker output.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final references = <String>{};
      for (final box in [
        HiveBoxes.dogsBoxName,
        HiveBoxes.bookingsBoxName,
        HiveBoxes.sittersBoxName,
      ]) {
        for (final raw in HiveBoxes.getValues(box)) {
          if (raw is! Map) continue;
          final photo =
              raw[box == HiveBoxes.dogsBoxName
                  ? 'photoPath'
                  : box == HiveBoxes.bookingsBoxName
                  ? 'petPhotoPath'
                  : 'imagePath'];
          if (photo is String && photo.isNotEmpty) references.add(photo);
          if (box == HiveBoxes.sittersBoxName && raw['galleryPaths'] is List) {
            references.addAll(
              (raw['galleryPaths'] as List).whereType<String>(),
            );
          }
        }
      }
      unawaited(
        storage.pruneOrphanedPhotos(references).catchError((Object _) {}),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _opening = _initialize();
  }

  @override
  void dispose() {
    _resumeListener?.dispose();
    _resumeListener = null;
    final resumed = _resumed;
    if (resumed != null && !resumed.isCompleted) resumed.complete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: _opening,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          !snapshot.hasError) {
        return const PawCareApp(
          startWithSplash: true,
          respectFirstLaunch: true,
        );
      }
      return MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: snapshot.hasError
            ? _buildOpeningError()
            : SplashScreen(onFinished: () {}, autoFinish: false),
      );
    },
  );

  Widget _buildOpeningError() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storage_outlined, size: AppDimens.iconHero),
                const SizedBox(height: AppDimens.p16),
                const Text(AppStrings.startupErrorTitle),
                const SizedBox(height: AppDimens.p8),
                const Text(
                  AppStrings.startupErrorBody,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimens.p16),
                FilledButton(
                  onPressed: () {
                    final opening = _initialize();
                    setState(() {
                      _opening = opening;
                    });
                  },
                  child: const Text(AppStrings.retry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
