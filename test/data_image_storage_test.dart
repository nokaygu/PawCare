import 'dart:async';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/core/utils/image_storage_service.dart';
import 'package:paw_care/core/widgets/paw_avatar_image.dart';

Future<void> _loadImage(ImageProvider provider) async {
  final completer = Completer<void>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, synchronousCall) {
      info.dispose();
      stream.removeListener(listener);
      completer.complete();
    },
    onError: (Object error, StackTrace? stackTrace) {
      stream.removeListener(listener);
      completer.completeError(error, stackTrace);
    },
  );
  stream.addListener(listener);
  await completer.future;
}

void main() {
  testWidgets('Managed photo removal evicts both image provider caches', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'pawcare_images_',
      );
      try {
        final petsDir = await Directory('${directory.path}/pawcare_pets')
            .create();
        final photo = await File('assets/images/barley.jpg')
            .copy('${petsDir.path}/old.jpg');
        final original = await File('assets/images/barley.jpg')
            .copy('${directory.path}/original.jpg');
        final service = ImageStorageService(
          documentsDirectory: () async => directory,
        );
        final fileProvider = FileImage(photo);
        final avatarProvider = PawImageProvider.resolve(photo.path);
        await _loadImage(fileProvider);
        await _loadImage(avatarProvider);
        final fileKey = await fileProvider.obtainKey(ImageConfiguration.empty);
        final avatarKey = await avatarProvider.obtainKey(
          ImageConfiguration.empty,
        );
        final cache = PaintingBinding.instance.imageCache;
        expect(cache.containsKey(fileKey), isTrue);
        expect(cache.containsKey(avatarKey), isTrue);

        await service.deletePetPhoto(photo.path);

        expect(await photo.exists(), isFalse);
        expect(cache.containsKey(fileKey), isFalse);
        expect(cache.containsKey(avatarKey), isFalse);
        await service.deletePetPhoto(original.path);
        await service.deletePetPhoto('assets/images/barley.jpg');
        await service.deletePetPhoto(photo.path);
        expect(await original.exists(), isTrue);
      } finally {
        await directory.delete(recursive: true);
      }
    });
  });

  testWidgets('Avatar providers load a bundled fallback for missing files', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final directory = await Directory.systemTemp.createTemp(
        'pawcare_missing_',
      );
      final provider = PawImageProvider.resolve(
        '${directory.path}/missing.jpg',
      );
      try {
        await _loadImage(provider);
        final key = await provider.obtainKey(ImageConfiguration.empty);
        expect(PaintingBinding.instance.imageCache.containsKey(key), isTrue);
      } finally {
        await provider.evict();
        await directory.delete(recursive: true);
      }
    });
    expect(tester.takeException(), isNull);
  });
}
