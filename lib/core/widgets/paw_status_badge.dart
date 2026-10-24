import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

class PawStatusBadge extends StatelessWidget {
  final BookingStatus status;

  const PawStatusBadge({super.key, required this.status});

  (Color, Color, String) _resolveVisuals(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return switch (status) {
      BookingStatus.confirmed => (
        pawTheme.successContainer,
        pawTheme.success,
        AppStrings.statusConfirmed,
      ),
      BookingStatus.pending => (
        colors.secondaryContainer,
        colors.primary,
        AppStrings.statusPending,
      ),
      BookingStatus.rejected => (
        colors.errorContainer,
        colors.error,
        AppStrings.statusRejected,
      ),
      BookingStatus.completed => (
        pawTheme.surfaceContainerLow,
        colors.onSurfaceVariant,
        AppStrings.statusCompleted,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    final (bg, fg, label) = _resolveVisuals(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p10,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(label, style: textTheme.labelSmall?.copyWith(color: fg)),
    );
  }
}
