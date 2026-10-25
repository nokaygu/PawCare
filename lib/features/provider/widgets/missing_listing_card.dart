import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';

class MissingListingCard extends StatelessWidget {
  final VoidCallback onAccounts;
  const MissingListingCard({super.key, required this.onAccounts});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppDimens.paddingLg),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.missingListingTitle,
          style: context.pawTextTheme.titleLarge,
        ),
        const SizedBox(height: AppDimens.p12),
        const Text(AppStrings.missingListingBody),
        const SizedBox(height: AppDimens.p12),
        FilledButton(
          onPressed: onAccounts,
          child: const Text(AppStrings.openAccounts),
        ),
      ],
    ),
  );
}
