import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PawImageProvider {
  const PawImageProvider._();

  static ImageProvider resolve(String path) {
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    if (path.isEmpty) return const AssetImage('assets/images/barley.jpg');
    return _FallbackFileImage(File(path));
  }

  static Future<bool> evict(String path) => resolve(path).evict();
}

class _FallbackFileImage extends FileImage {
  const _FallbackFileImage(super.file);

  @override
  ImageStreamCompleter loadImage(FileImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadImage(decode),
      scale: key.scale,
      debugLabel: file.path,
    );
  }

  Future<ui.Codec> _loadImage(ImageDecoderCallback decode) async {
    try {
      final bytes = await file.readAsBytes();
      return await decode(await ui.ImmutableBuffer.fromUint8List(bytes));
    } catch (_) {
      final fallback = await rootBundle.load('assets/images/barley.jpg');
      return decode(
        await ui.ImmutableBuffer.fromUint8List(
          fallback.buffer.asUint8List(
            fallback.offsetInBytes,
            fallback.lengthInBytes,
          ),
        ),
      );
    }
  }
}

class PawBoxImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const PawBoxImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: fit);
    }
    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/barley.jpg',
        width: width,
        height: height,
        fit: fit,
      ),
    );
  }
}
