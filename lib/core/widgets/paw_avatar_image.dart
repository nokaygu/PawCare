import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../theme/app_theme.dart';

class PawImageProvider {
  const PawImageProvider._();
  // A neutral transparent pixel never substitutes another person's/pet's photo.
  static final _empty = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGNgYGBgAAAABQABpfZFQAAAAABJRU5ErkJggg==',
  );
  static const _sizes = [64, 128, 192, 256, 512, 1024, 1600];
  static ImageProvider _base(String path) => path.isEmpty
      ? MemoryImage(_empty)
      : path.startsWith('assets/')
      ? AssetImage(path)
      : _FallbackFileImage(File(path));
  static ImageProvider resolve(String path, {int cacheWidth = 192}) {
    final size = _sizes.firstWhere(
      (size) => size >= cacheWidth,
      orElse: () => _sizes.last,
    );
    return ResizeImage(
      _base(path),
      width: size,
      height: size,
      policy: ResizeImagePolicy.fit,
    );
  }

  static ImageProvider avatar(
    BuildContext context,
    String path, {
    required double radius,
  }) => resolve(
    path,
    cacheWidth: (radius * 2 * MediaQuery.devicePixelRatioOf(context)).ceil(),
  );

  static Future<bool> evict(String path) async {
    var evicted = await _base(path).evict();
    for (final size in _sizes) {
      evicted = await resolve(path, cacheWidth: size).evict() || evicted;
    }
    return evicted;
  }
}

class _FallbackFileImage extends FileImage {
  const _FallbackFileImage(super.file);
  @override
  ImageStreamCompleter loadImage(FileImage key, ImageDecoderCallback decode) =>
      MultiFrameImageStreamCompleter(
        codec: _loadImage(decode),
        scale: key.scale,
        debugLabel: file.path,
      );
  Future<ui.Codec> _loadImage(ImageDecoderCallback decode) async {
    try {
      return await decode(await ui.ImmutableBuffer.fromFilePath(file.path));
    } catch (_) {
      return decode(
        await ui.ImmutableBuffer.fromUint8List(PawImageProvider._empty),
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
  Widget _placeholder(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: ColoredBox(
      color: context.pawTheme.surfaceContainerLow,
      child: Icon(
        Icons.pets_outlined,
        size: AppDimens.iconXl,
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    if (path.isEmpty) return _placeholder(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final logicalWidth = width?.isFinite == true
            ? width!
            : constraints.hasBoundedWidth
            ? constraints.maxWidth
            : AppDimens.thumbMd;
        final target = (logicalWidth * MediaQuery.devicePixelRatioOf(context))
            .ceil();
        return Image(
          image: PawImageProvider.resolve(path, cacheWidth: target),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, _, _) => _placeholder(context),
        );
      },
    );
  }
}
