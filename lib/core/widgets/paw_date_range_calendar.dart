import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';
import '../constants/app_strings.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';

class PawDateRangeCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final List<DateTime> unavailableDates;
  final void Function(DateTime? start, DateTime? end)? onRangeChanged;
  final ValueChanged<DateTime>? onDayTapped;

  const PawDateRangeCalendar({
    super.key,
    required this.initialMonth,
    this.rangeStart,
    this.rangeEnd,
    this.unavailableDates = const <DateTime>[],
    this.onRangeChanged,
    this.onDayTapped,
  });

  @override
  State<PawDateRangeCalendar> createState() => _PawDateRangeCalendarState();
}

class _PawDateRangeCalendarState extends State<PawDateRangeCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + delta,
      );
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isUnavailable(DateTime day) {
    return widget.unavailableDates.any((d) => _isSameDay(d, day));
  }

  bool _rangeIncludesUnavailable(DateTime start, DateTime end) {
    final firstDay = DateUtils.dateOnly(start);
    final lastDay = DateUtils.dateOnly(end);
    return widget.unavailableDates.any((date) {
      final day = DateUtils.dateOnly(date);
      return !day.isBefore(firstDay) && !day.isAfter(lastDay);
    });
  }

  void _handleDayTap(DateTime day) {
    if (widget.onDayTapped != null) {
      widget.onDayTapped!(day);
      return;
    }
    if (_isUnavailable(day) || widget.onRangeChanged == null) return;

    final start = widget.rangeStart;
    final end = widget.rangeEnd;
    if (start == null || end != null) {
      widget.onRangeChanged!(day, null);
      return;
    }

    final rangeStart = day.isBefore(start) ? day : start;
    final rangeEnd = _isSameDay(day, start)
        ? DateTime(day.year, day.month, day.day + 1)
        : day.isBefore(start)
        ? start
        : day;
    if (_rangeIncludesUnavailable(rangeStart, rangeEnd)) return;
    widget.onRangeChanged!(rangeStart, rangeEnd);
  }

  @override
  Widget build(BuildContext context) {
    final monthTitle =
        '${AppStrings.monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final firstWeekday = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    ).weekday;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _CalendarHeader(
          title: monthTitle,
          onPrev: () => _changeMonth(-1),
          onNext: () => _changeMonth(1),
        ),
        const SizedBox(height: AppDimens.p8),
        const _WeekdayHeaderRow(weekDays: AppStrings.weekDays),
        const SizedBox(height: AppDimens.p6),
        _MonthDaysGrid(
          displayedMonth: _displayedMonth,
          daysInMonth: daysInMonth,
          leadingEmptyCount: firstWeekday - 1,
          rangeStart: widget.rangeStart,
          rangeEnd: widget.rangeEnd,
          isUnavailable: _isUnavailable,
          onDayTap: _handleDayTap,
        ),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final String title;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CalendarHeader({
    required this.title,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          onPressed: onPrev,
          icon: Icon(
            Icons.chevron_left,
            color: colors.primary,
            size: AppDimens.iconLg,
          ),
        ),
        Text(title, style: textTheme.titleMedium),
        IconButton(
          onPressed: onNext,
          icon: Icon(
            Icons.chevron_right,
            color: colors.primary,
            size: AppDimens.iconLg,
          ),
        ),
      ],
    );
  }
}

class _WeekdayHeaderRow extends StatelessWidget {
  final List<String> weekDays;

  const _WeekdayHeaderRow({required this.weekDays});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(child: Text(day, style: textTheme.bodySmall)),
        );
      }).toList(),
    );
  }
}

class _MonthDaysGrid extends StatelessWidget {
  final DateTime displayedMonth;
  final int daysInMonth;
  final int leadingEmptyCount;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool Function(DateTime) isUnavailable;
  final ValueChanged<DateTime> onDayTap;

  const _MonthDaysGrid({
    required this.displayedMonth,
    required this.daysInMonth,
    required this.leadingEmptyCount,
    required this.rangeStart,
    required this.rangeEnd,
    required this.isUnavailable,
    required this.onDayTap,
  });

  bool _sameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _inRange(DateTime day) {
    if (rangeStart == null || rangeEnd == null) return false;
    return day.isAfter(rangeStart!) && day.isBefore(rangeEnd!);
  }

  Widget _buildCell(int rowIdx, int colIdx) {
    final cellIndex = rowIdx * 7 + colIdx;
    final dayNum = cellIndex - leadingEmptyCount + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const Expanded(
        child: SizedBox(height: AppDimens.calendarDayCellSize),
      );
    }
    final date = DateTime(displayedMonth.year, displayedMonth.month, dayNum);
    return Expanded(
      child: _CalendarDayCell(
        dayNumber: dayNum,
        isEdgeSelected: _sameDay(rangeStart, date) || _sameDay(rangeEnd, date),
        isInRange: _inRange(date),
        isBlocked: isUnavailable(date),
        onTap: () => onDayTap(date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCells = leadingEmptyCount + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      children: List<Widget>.generate(rowCount, (rowIdx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimens.p2),
          child: Row(
            children: List<Widget>.generate(
              7,
              (colIdx) => _buildCell(rowIdx, colIdx),
            ),
          ),
        );
      }),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final int dayNumber;
  final bool isEdgeSelected;
  final bool isInRange;
  final bool isBlocked;
  final VoidCallback onTap;

  const _CalendarDayCell({
    required this.dayNumber,
    required this.isEdgeSelected,
    required this.isInRange,
    required this.isBlocked,
    required this.onTap,
  });

  (Color, Color) _resolveColors(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final bg = isEdgeSelected
        ? colors.primary
        : isInRange
        ? colors.secondaryContainer
        : isBlocked
        ? colors.errorContainer.withValues(alpha: AppDimens.alphaMedium)
        : pawTheme.transparent;
    final fg = isEdgeSelected
        ? colors.onPrimary
        : isBlocked
        ? colors.error
        : colors.onSurface;
    return (bg, fg);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    final (bgColor, fgColor) = _resolveColors(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: Container(
        height: AppDimens.calendarDayCellSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          shape: isEdgeSelected ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isEdgeSelected
              ? null
              : BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Text(
          '$dayNumber',
          style: isEdgeSelected
              ? AppTypography.toBold(textTheme.bodyMedium!, color: fgColor)
              : textTheme.bodyMedium?.copyWith(color: fgColor),
        ),
      ),
    );
  }
}
