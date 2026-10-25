import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../../data/models/models.dart';
import '../paw_avatar_image.dart';

class LiveTrackingModal extends StatelessWidget {
  final BookingRequest booking;
  const LiveTrackingModal({super.key, required this.booking});

  static Future<void> show(
    BuildContext context, {
    required BookingRequest booking,
  }) {
    if (booking.serviceType != ServiceType.walk ||
        !booking.isActiveAt(DateTime.now())) {
      return Future<void>.value();
    }
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => LiveTrackingModal(booking: booking),
    );
  }

  BoxDecoration _dialogDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.modalRadius),
      boxShadow: pawTheme.floatingShadow,
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDimens.modalBlurSigma,
        sigmaY: AppDimens.modalBlurSigma,
      ),
      child: Dialog(
        backgroundColor: pawTheme.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingLg,
          vertical: AppDimens.paddingXl,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxShellWidth),
          decoration: _dialogDecoration(colors, pawTheme),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.paddingXl),
            child: _LiveTrackingBody(booking: booking),
          ),
        ),
      ),
    );
  }
}

class _LiveTrackingBody extends StatelessWidget {
  final BookingRequest booking;
  const _LiveTrackingBody({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _LiveTrackingHeader(),
        const SizedBox(height: AppDimens.p16),
        _StylizedDemoMap(booking: booking),
        const SizedBox(height: AppDimens.p16),
        const _LiveStatsRow(),
        const SizedBox(height: AppDimens.p14),
        const _DemoInfoNote(),
      ],
    );
  }
}

class _LiveTrackingHeader extends StatelessWidget {
  const _LiveTrackingHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: AppDimens.dotLg,
              height: AppDimens.dotLg,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pawTheme.success,
              ),
            ),
            const SizedBox(width: AppDimens.p8),
            Text(
              AppStrings.liveWalkTrackingTitle,
              style: textTheme.titleMedium,
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.close, color: colors.onSurfaceVariant),
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: pawTheme.surfaceContainerLow,
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }
}

class _StylizedDemoMap extends StatelessWidget {
  final BookingRequest booking;
  const _StylizedDemoMap({required this.booking});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Container(
      height: AppDimens.liveMapHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: pawTheme.mapParkGreen,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaMedium),
        ),
      ),
      child: Stack(
        children: <Widget>[
          const _MapSeaLayer(),
          const _MapParkBadge(),
          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePainter(
                routeColor: colors.primaryContainer,
                startColor: colors.primary,
              ),
            ),
          ),
          Positioned(
            top: AppDimens.liveMapPinTop,
            left: AppDimens.liveMapPinLeft,
            child: _WalkerPinAvatar(booking: booking),
          ),
        ],
      ),
    );
  }
}

class _MapSeaLayer extends StatelessWidget {
  const _MapSeaLayer();

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Positioned(
      left: AppDimens.zero,
      right: AppDimens.zero,
      bottom: AppDimens.zero,
      height: AppDimens.liveMapSeaHeight,
      child: Container(
        decoration: BoxDecoration(
          color: pawTheme.mapSeaBlue,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppDimens.cardRadius),
          ),
        ),
        alignment: Alignment.bottomRight,
        padding: const EdgeInsets.all(AppDimens.p12),
        child: Text(
          AppStrings.marmaraSeaLabel,
          style: AppTypography.toSemiBold(
            textTheme.bodySmall!,
            color: pawTheme.mapSeaText,
          ),
        ),
      ),
    );
  }
}

class _MapParkBadge extends StatelessWidget {
  const _MapParkBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Positioned(
      top: AppDimens.p20,
      left: AppDimens.p20,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p10,
          vertical: AppDimens.p4,
        ),
        decoration: BoxDecoration(
          color: pawTheme.glassBadge,
          borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        ),
        child: Text(
          AppStrings.defaultWalkLocation,
          style: AppTypography.toBold(
            textTheme.bodySmall!,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _WalkerPinAvatar extends StatelessWidget {
  final BookingRequest booking;
  const _WalkerPinAvatar({required this.booking});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Column(
      children: <Widget>[
        _buildAvatar(context),
        Container(
          margin: const EdgeInsets.only(top: AppDimens.p4),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p8,
            vertical: AppDimens.p2,
          ),
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Text(
            AppStrings.trackingPair(booking.sitterName, booking.petName),
            style: textTheme.labelSmall?.copyWith(color: colors.onPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.p3),
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
        boxShadow: pawTheme.cardShadow,
      ),
      child: CircleAvatar(
        radius: AppDimens.avatarRadiusXs,
        backgroundImage: PawImageProvider.avatar(
          context,
          booking.sitterPhoto,
          radius: AppDimens.avatarRadiusXs,
        ),
      ),
    );
  }
}

class _LiveStatsRow extends StatelessWidget {
  const _LiveStatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: <Widget>[
        Expanded(
          child: _LiveStatCard(
            label: AppStrings.elapsedTimeLabel,
            value: AppStrings.elapsedTimeValue,
          ),
        ),
        SizedBox(width: AppDimens.p12),
        Expanded(
          child: _LiveStatCard(
            label: AppStrings.walkDistanceLabel,
            value: AppStrings.walkDistanceValue,
          ),
        ),
      ],
    );
  }
}

class _LiveStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _LiveStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.p14),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: textTheme.bodySmall),
          const SizedBox(height: AppDimens.p4),
          Text(value, style: textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _DemoInfoNote extends StatelessWidget {
  const _DemoInfoNote();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimens.p12),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(
          alpha: AppDimens.alphaStrong,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: AppDimens.iconSm,
            color: colors.secondary,
          ),
          const SizedBox(width: AppDimens.p10),
          Expanded(
            child: Text(
              AppStrings.liveTrackingDemoDisclaimer,
              style: textTheme.bodySmall?.copyWith(color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final Color routeColor;
  final Color startColor;

  const _RoutePainter({required this.routeColor, required this.startColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = routeColor
      ..strokeWidth = AppDimens.routeStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(40, 140)
      ..quadraticBezierTo(90, 80, 140, 110)
      ..quadraticBezierTo(170, 130, 190, 100);

    canvas.drawPath(path, paint);

    final startPaint = Paint()..color = startColor;
    canvas.drawCircle(
      const Offset(40, 140),
      AppDimens.routeDotRadius,
      startPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.routeColor != routeColor ||
        oldDelegate.startColor != startColor;
  }
}
