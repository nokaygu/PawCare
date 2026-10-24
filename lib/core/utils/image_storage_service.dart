import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/paw_avatar_image.dart';

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
    );
    if (pickedFile == null) {
      return null;
    }

    final Directory petsDir = await _petsDirectory();
    if (!await petsDir.exists()) {
      await petsDir.create(recursive: true);
    }

    final String extension = pickedFile.name.contains('.')
        ? pickedFile.name.substring(pickedFile.name.lastIndexOf('.'))
        : '.jpg';
    final String fileName =
        'pet_${DateTime.now().microsecondsSinceEpoch}$extension';
    final String savedPath = '${petsDir.path}/$fileName';

    final File sourceFile = File(pickedFile.path);
    await sourceFile.copy(savedPath);
    return savedPath;
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
