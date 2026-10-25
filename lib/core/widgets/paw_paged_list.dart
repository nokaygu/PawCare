import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_limits.dart';
import '../constants/app_strings.dart';

/// Bounded pages for a list embedded in a surrounding scroll view.
class PawPagedList extends StatefulWidget {
  final int itemCount;
  final String? storageId;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  const PawPagedList({
    super.key,
    required this.itemCount,
    this.storageId,
    required this.itemBuilder,
    required this.separatorBuilder,
  });
  @override
  State<PawPagedList> createState() => _PawPagedListState();
}

class _PawPagedListState extends State<PawPagedList> {
  int _page = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.storageId != null) {
      final saved = PageStorage.maybeOf(context)
          ?.readState(context, identifier: widget.storageId);
      if (saved is int) _page = saved;
    }
  }

  void _go(int page) {
    setState(() {
      _page = page;
    });
    if (widget.storageId != null) {
      PageStorage.maybeOf(context)
          ?.writeState(context, page, identifier: widget.storageId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = math.max(
      1,
      (widget.itemCount / AppLimits.sectionPageSize).ceil(),
    );
    _page = math.min(_page, pages - 1);
    final start = _page * AppLimits.sectionPageSize;
    final end = math.min(start + AppLimits.sectionPageSize, widget.itemCount);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = start; i < end; i++) ...[
          if (i > start) widget.separatorBuilder(context, i - 1),
          widget.itemBuilder(context, i),
        ],
        if (pages > 1)
          Padding(
            padding: const EdgeInsets.only(top: AppDimens.p12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: AppStrings.previousPage,
                  onPressed: _page == 0 ? null : () => _go(_page - 1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(AppStrings.pageInfo(_page + 1, pages)),
                IconButton(
                  tooltip: AppStrings.nextPage,
                  onPressed: _page == pages - 1 ? null : () => _go(_page + 1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
