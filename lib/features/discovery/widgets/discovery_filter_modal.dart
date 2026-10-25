import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/discovery_controller.dart';

class DiscoveryFilterModal extends StatefulWidget {
  final DiscoveryController controller;
  const DiscoveryFilterModal({super.key, required this.controller});
  static Future<void> show(
    BuildContext context, {
    required DiscoveryController controller,
  }) => showDialog<void>(
    context: context,
    barrierColor: context.pawTheme.modalBarrier,
    builder: (_) => DiscoveryFilterModal(controller: controller),
  );
  @override
  State<DiscoveryFilterModal> createState() => _DiscoveryFilterModalState();
}

class _DiscoveryFilterModalState extends State<DiscoveryFilterModal> {
  double? _maxPrice;
  late bool _sortByPrice;
  @override
  void initState() {
    super.initState();
    _maxPrice = widget.controller.value.maxPrice;
    _sortByPrice = widget.controller.value.sortByPriceAsc;
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    backgroundColor: context.pawTheme.surfaceContainerLowest,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
    ),
    title: const Text(AppStrings.advancedFilterTitle),
    content: _buildDraftFields(context),
    actions: [
      _buildResetAction(),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(AppStrings.cancel),
      ),
      ElevatedButton(
        onPressed: () {
          widget.controller.applyFilters(
            maxPrice: _maxPrice,
            sortByPriceAsc: _sortByPrice,
          );
          Navigator.of(context).pop();
        },
        child: const Text(AppStrings.apply),
      ),
    ],
  );

  Widget _buildDraftFields(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.maxPriceLabel(_maxPrice),
            style: context.pawTextTheme.titleMedium,
          ),
          const SizedBox(height: AppDimens.p8),
          Wrap(
            spacing: AppDimens.p8,
            children: [
              for (final budget in <double?>[null, 400, 750, 1500])
                ChoiceChip(
                  selected: _maxPrice == budget,
                  label: Text(
                    budget == null
                        ? AppStrings.budgetUnlimited
                        : AppStrings.budgetChipLabel(budget),
                  ),
                  onSelected: (_) => setState(() => _maxPrice = budget),
                ),
            ],
          ),
          const SizedBox(height: AppDimens.p16),
          Text(
            AppStrings.sortCriteriaTitle,
            style: context.pawTextTheme.titleMedium,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(AppStrings.sortByLowestPriceLabel),
            value: _sortByPrice,
            onChanged: (value) => setState(() => _sortByPrice = value),
          ),
        ],
      ),
    );
  }

  Widget _buildResetAction() {
    return TextButton(
      onPressed: () => setState(() {
        _maxPrice = null;
        _sortByPrice = false;
      }),
      child: const Text(AppStrings.reset),
    );
  }
}
