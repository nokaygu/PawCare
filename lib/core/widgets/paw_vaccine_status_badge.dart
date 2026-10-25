import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';

class PawVaccineStatusBadge extends StatelessWidget {
  final VaccineStatus status;
  const PawVaccineStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (background, foreground, label) = switch (status) {
      VaccineStatus.completed => (
        context.pawTheme.successContainer,
        context.pawTheme.success,
        AppStrings.statusCompleted,
      ),
      VaccineStatus.overdue => (
        colors.errorContainer,
        colors.error,
        AppStrings.statusOverdue,
      ),
      VaccineStatus.upcoming => (
        colors.secondaryContainer,
        colors.primary,
        AppStrings.statusUpcoming,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p8,
        vertical: AppDimens.p4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      ),
      child: Text(
        label,
        style: context.pawTextTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}
