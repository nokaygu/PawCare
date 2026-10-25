import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/paw_avatar_image.dart';
import '../constants/app_limits.dart';
import 'record_id.dart';

class ImageStorageService {
  final ImagePicker _picker;
  final Future<Directory> Function() _documentsDirectory;

  ImageStorageService({
    ImagePicker? picker,
    Future<Directory> Function()? documentsDirectory,
  }) : _picker = picker ?? ImagePicker(),
       _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  Future<Directory> _petsDirectory() async {
    final appDocDir = await _documentsDirectory();
    return Directory('${appDocDir.path}/pawcare_pets');
  }

  Future<String?> pickAndSavePetPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: AppLimits.photoMaxSide,
      maxHeight: AppLimits.photoMaxSide,
      requestFullMetadata: false,
    );
    if (pickedFile == null) {
      return null;
    }

    return savePickedPhoto(pickedFile);
  }

  Future<String?> recoverLostPetPhoto() async {
    if (kIsWeb || !Platform.isAndroid) return null;
    final response = await _picker.retrieveLostData();
    if (response.exception != null) throw response.exception!;
    final file = response.files?.firstOrNull;
    return file == null ? null : savePickedPhoto(file);
  }

  Future<void> pruneOrphanedPhotos(
    Set<String> referenced, {
    DateTime? now,
  }) async {
    if (kIsWeb) return;
    final directory = await _petsDirectory();
    if (!await directory.exists()) return;
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 1));
    await for (final file in directory.list(followLinks: false)) {
      if (file is! File || referenced.contains(file.path)) continue;
      if (!(await file.lastModified()).isBefore(cutoff)) continue;
      await deletePetPhoto(file.path);
    }
  }

  Future<String> savePickedPhoto(XFile pickedFile) async {
    final Directory petsDir = await _petsDirectory();
    if (!await petsDir.exists()) {
      await petsDir.create(recursive: true);
    }

    final buffer = await ui.ImmutableBuffer.fromFilePath(pickedFile.path);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      final side = math.max(descriptor.width, descriptor.height);
      final scale = math.min(1.0, AppLimits.photoMaxSide / side);
      final extension = scale < 1
          ? '.png'
          : pickedFile.name.contains('.')
          ? pickedFile.name.substring(pickedFile.name.lastIndexOf('.'))
          : '.jpg';
      final savedPath = '${petsDir.path}/${RecordId.create('pet')}$extension';
      if (scale == 1) {
        await File(pickedFile.path).copy(savedPath);
      } else {
        // Desktop pickers do not resize. Decode directly at the bounded size.
        final codec = await descriptor.instantiateCodec(
          targetWidth: (descriptor.width * scale).round(),
          targetHeight: (descriptor.height * scale).round(),
        );
        try {
          final frame = await codec.getNextFrame();
          try {
            final bytes = await frame.image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            if (bytes == null) throw StateError('Photo encoding failed');
            await File(savedPath)
                .writeAsBytes(bytes.buffer.asUint8List(), flush: true);
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }
      }
      return savedPath;
    } finally {
      descriptor.dispose();
      buffer.dispose();
    }
  }

  Future<void> deletePetPhoto(String path) async {
    if (path.isEmpty || path.startsWith('assets/')) return;
    final file = File(path);
    await FileImage(file).evict();
    await PawImageProvider.evict(path);

    // Only files copied into the app's pet directory belong to this service.
    // Gallery originals and other user files must remain intact.
    try {
      final petsDir = await _petsDirectory();
      if (!await petsDir.exists() || !await file.exists()) return;
      final ownedDirectory = await petsDir.resolveSymbolicLinks();
      final resolvedPath = await file.resolveSymbolicLinks();
      if (!resolvedPath.startsWith(
        '$ownedDirectory${Platform.pathSeparator}',
      )) {
        return;
      }
      await file.delete();
    } on FileSystemException {
      // A missing or unavailable old photo must not undo the saved profile.
    }
  }
}
