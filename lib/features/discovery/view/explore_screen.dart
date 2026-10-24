import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_header_actions.dart';
import '../../../data/models/models.dart';
import '../controller/discovery_controller.dart';
import '../widgets/explore_sitter_card.dart';

class ExploreScreen extends StatelessWidget {
  final DiscoveryController controller;
  final ValueChanged<SitterListing> onSitterSelected;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const ExploreScreen({
    super.key,
    required this.controller,
    required this.onSitterSelected,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final pawTheme = context.pawTheme;

    return Scaffold(
      backgroundColor: pawTheme.background,
      body: SafeArea(
        child: ValueListenableBuilder<DiscoveryFilterState>(
          valueListenable: controller,
          builder: (context, state, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingLg,
                vertical: AppDimens.paddingLg,
              ),
              child: _ExploreContent(
                state: state,
                categories: AppStrings.exploreCategories,
                controller: controller,
                onSitterSelected: onSitterSelected,
                unreadNotifications: unreadNotifications,
                onNotificationsTap: onNotificationsTap,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExploreContent extends StatelessWidget {
  final DiscoveryFilterState state;
  final List<String> categories;
  final DiscoveryController controller;
  final ValueChanged<SitterListing> onSitterSelected;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _ExploreContent({
    required this.state,
    required this.categories,
    required this.controller,
    required this.onSitterSelected,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  Widget _buildSittersList(List<SitterListing> sitters) {
    if (sitters.isEmpty) {
      return _ExploreEmptyResultsCard(onReset: controller.resetFilters);
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sitters.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p16),
      itemBuilder: (context, index) {
        final s = sitters[index];
        return ExploreSitterCard(
          sitter: s,
          onInspectTap: () => onSitterSelected(s),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sitters = state.filteredSitters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ExploreTopBar(
          controller: controller,
          unreadNotifications: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
        const SizedBox(height: AppDimens.p16),
        _ExploreSearchField(
          searchQuery: state.searchQuery,
          onChanged: controller.setSearchQuery,
        ),
        const SizedBox(height: AppDimens.p16),
        _ExploreCategoryChips(
          categories: categories,
          selectedCategory: state.selectedCategory,
          onSelected: controller.setCategory,
        ),
        const SizedBox(height: AppDimens.p18),
        _ExploreCountBanner(
          count: sitters.length,
          searchQuery: state.searchQuery,
          selectedCategory: state.selectedCategory,
        ),
        const SizedBox(height: AppDimens.p14),
        _buildSittersList(sitters),
        const SizedBox(height: AppDimens.p20),
      ],
    );
  }
}

class _ExploreTopBar extends StatelessWidget {
  final DiscoveryController controller;
  final int unreadNotifications;
  final VoidCallback onNotificationsTap;

  const _ExploreTopBar({
    required this.controller,
    required this.unreadNotifications,
    required this.onNotificationsTap,
  });

  ButtonStyle _tuneButtonStyle(ColorScheme colors, PawThemeExtension pawTheme) {
    return IconButton.styleFrom(
      backgroundColor: pawTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        side: BorderSide(
          color: colors.outlineVariant.withValues(alpha: AppDimens.alphaLight),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        const Expanded(child: _ExploreTitleColumn()),
        IconButton(
          icon: Icon(Icons.tune, color: colors.primary),
          onPressed: () =>
              _ExploreFilterModal.show(context, controller: controller),
          style: _tuneButtonStyle(colors, pawTheme),
        ),
        const SizedBox(width: AppDimens.p8),
        PawHeaderActions(
          unreadCount: unreadNotifications,
          onNotificationsTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _ExploreFilterModal extends StatelessWidget {
  final DiscoveryController controller;

  const _ExploreFilterModal({required this.controller});

  static Future<void> show(
    BuildContext context, {
    required DiscoveryController controller,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) => _ExploreFilterModal(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return ValueListenableBuilder<DiscoveryFilterState>(
      valueListenable: controller,
      builder: (context, state, _) {
        return AlertDialog(
          backgroundColor: pawTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
          ),
          title: Text(
            AppStrings.advancedFilterTitle,
            style: textTheme.titleLarge,
          ),
          content: _FilterModalContent(state: state, controller: controller),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                controller.resetFilters();
                Navigator.of(context).pop();
              },
              child: Text(AppStrings.reset, style: textTheme.bodyLarge),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: const Text(AppStrings.apply),
            ),
          ],
        );
      },
    );
  }
}

class _FilterModalContent extends StatelessWidget {
  final DiscoveryFilterState state;
  final DiscoveryController controller;

  const _FilterModalContent({required this.state, required this.controller});

  static const List<double> _priceBudgets = <double>[400.0, 750.0, 1500.0];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppStrings.maxPriceLabel(state.maxPrice),
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: AppDimens.p8),
        Wrap(
          spacing: AppDimens.p8,
          children: _priceBudgets.map((budget) {
            final selected = state.maxPrice == budget;
            return ChoiceChip(
              selected: selected,
              label: Text(AppStrings.budgetChipLabel(budget)),
              selectedColor: colors.secondaryContainer,
              onSelected: (_) => controller.setMaxPrice(budget),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimens.p16),
        Text(AppStrings.sortCriteriaTitle, style: textTheme.titleMedium),
        const SizedBox(height: AppDimens.p8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            AppStrings.sortByLowestPriceLabel,
            style: textTheme.bodyLarge,
          ),
          value: state.sortByPriceAsc,
          onChanged: controller.setSortByPriceAsc,
        ),
      ],
    );
  }
}

class _ExploreTitleColumn extends StatelessWidget {
  const _ExploreTitleColumn();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.p8,
            vertical: AppDimens.p4,
          ),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.pets, size: AppDimens.iconXxs, color: colors.primary),
              const SizedBox(width: AppDimens.p4),
              Text(
                AppStrings.roleOwner,
                style: textTheme.labelSmall?.copyWith(color: colors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.p6),
        Text(AppStrings.exploreHeaderTitle, style: textTheme.headlineMedium),
      ],
    );
  }
}

class _ExploreSearchField extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onChanged;

  const _ExploreSearchField({
    required this.searchQuery,
    required this.onChanged,
  });

  @override
  State<_ExploreSearchField> createState() => _ExploreSearchFieldState();
}

class _ExploreSearchFieldState extends State<_ExploreSearchField> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _ExploreSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textController.text != widget.searchQuery) {
      _textController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(
    Color color, {
    double width = AppDimens.borderWidthThin,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    final subtleBorder = colors.outlineVariant.withValues(
      alpha: AppDimens.alphaLight,
    );
    return TextField(
      controller: _textController,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: AppStrings.exploreSearchHint,
        hintStyle: textTheme.bodyMedium,
        prefixIcon: Icon(Icons.search, color: colors.secondary),
        filled: true,
        fillColor: pawTheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p14,
        ),
        border: _border(subtleBorder),
        enabledBorder: _border(subtleBorder),
        focusedBorder: _border(
          colors.primary,
          width: AppDimens.borderWidthThick,
        ),
      ),
    );
  }
}

class _ExploreCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _ExploreCategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map(
              (cat) => _CategoryChipItem(
                category: cat,
                isSelected: selectedCategory == cat,
                onTap: () => onSelected(cat),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategoryChipItem extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChipItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.p8),
      child: FilterChip(
        selected: isSelected,
        label: Text(category),
        labelStyle: isSelected
            ? AppTypography.toBold(
                textTheme.bodyLarge!,
                color: colors.onPrimary,
              )
            : AppTypography.toMedium(
                textTheme.bodyLarge!,
                color: colors.onSurface,
              ),
        backgroundColor: pawTheme.surfaceContainerLowest,
        selectedColor: colors.primary,
        checkmarkColor: colors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
          side: BorderSide(
            color: isSelected
                ? colors.primary
                : colors.outlineVariant.withValues(
                    alpha: AppDimens.alphaMedium,
                  ),
          ),
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _ExploreCountBanner extends StatelessWidget {
  final int count;
  final String searchQuery;
  final String selectedCategory;

  const _ExploreCountBanner({
    required this.count,
    required this.searchQuery,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            AppStrings.exploreResultsCount(
              count: count,
              searchQuery: searchQuery,
              selectedCategory: selectedCategory,
            ),
            style: textTheme.titleMedium?.copyWith(color: colors.secondary),
          ),
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.location_on_outlined,
              size: AppDimens.iconXs,
              color: colors.secondary,
            ),
            const SizedBox(width: AppDimens.p2),
            Text(AppStrings.defaultCityLocation, style: textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _ExploreEmptyResultsCard extends StatelessWidget {
  final VoidCallback onReset;

  const _ExploreEmptyResultsCard({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingXl),
      decoration: BoxDecoration(
        color: context.pawTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.search_off, color: context.colors.secondary),
          const SizedBox(height: AppDimens.p12),
          Text(AppStrings.exploreEmptyTitle, style: textTheme.titleMedium),
          const SizedBox(height: AppDimens.p8),
          Text(
            AppStrings.exploreEmptySubtitle,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimens.p16),
          FilledButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text(AppStrings.clearFiltersButton),
          ),
        ],
      ),
    );
  }
}
