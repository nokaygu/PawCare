import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/widgets/paw_date_range_calendar.dart';

void main() {
  testWidgets('Rejects ranges that cross blocked days in either direction', (
    tester,
  ) async {
    final state = await _mountCalendar(tester, <DateTime>[
      DateTime(2026, 10, 29, 15),
      DateTime(2026, 10, 30),
    ]);

    await tester.tap(find.text('28'));
    await tester.pump();
    await tester.tap(find.text('31'));
    await tester.pump();
    expect(state.start, DateTime(2026, 10, 28));
    expect(state.end, isNull);

    state.reset();
    await tester.pump();
    await tester.tap(find.text('31'));
    await tester.pump();
    await tester.tap(find.text('28'));
    await tester.pump();
    expect(state.start, DateTime(2026, 10, 31));
    expect(state.end, isNull);
  });

  testWidgets('Accepts an available range and allows a new selection', (
    tester,
  ) async {
    final state = await _mountCalendar(tester, <DateTime>[
      DateTime(2026, 10, 29),
    ]);

    await tester.tap(find.text('27'));
    await tester.pump();
    await tester.tap(find.text('28'));
    await tester.pump();
    expect(state.start, DateTime(2026, 10, 27));
    expect(state.end, DateTime(2026, 10, 28));

    await tester.tap(find.text('26'));
    await tester.pump();
    expect(state.start, DateTime(2026, 10, 26));
    expect(state.end, isNull);
  });

  testWidgets('Same-day selection cannot extend into a blocked next day', (
    tester,
  ) async {
    final state = await _mountCalendar(tester, <DateTime>[
      DateTime(2026, 10, 29),
    ]);

    await tester.tap(find.text('28'));
    await tester.pump();
    await tester.tap(find.text('28'));
    await tester.pump();
    expect(state.start, DateTime(2026, 10, 28));
    expect(state.end, isNull);
  });

  testWidgets('Rejects a range crossing an unavailable day in another month', (
    tester,
  ) async {
    final state = await _mountCalendar(tester, <DateTime>[
      DateTime(2026, 11, 1),
    ]);

    await tester.tap(find.text('31'));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(state.start, DateTime(2026, 10, 31));
    expect(state.end, isNull);
  });

  testWidgets('Availability editor can still toggle a blocked day', (
    tester,
  ) async {
    DateTime? tapped;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: PawDateRangeCalendar(
            initialMonth: DateTime(2026, 10),
            unavailableDates: <DateTime>[DateTime(2026, 10, 29)],
            onDayTapped: (day) => tapped = day,
          ),
        ),
      ),
    );

    await tester.tap(find.text('29'));
    expect(tapped, DateTime(2026, 10, 29));
  });
}

Future<_CalendarHarnessState> _mountCalendar(
  WidgetTester tester,
  List<DateTime> unavailableDates,
) async {
  await tester.pumpWidget(_CalendarHarness(unavailableDates: unavailableDates));
  return tester.state<_CalendarHarnessState>(find.byType(_CalendarHarness));
}

class _CalendarHarness extends StatefulWidget {
  final List<DateTime> unavailableDates;

  const _CalendarHarness({required this.unavailableDates});

  @override
  State<_CalendarHarness> createState() => _CalendarHarnessState();
}

class _CalendarHarnessState extends State<_CalendarHarness> {
  DateTime? start;
  DateTime? end;

  void reset() => setState(() {
    start = null;
    end = null;
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: PawDateRangeCalendar(
          initialMonth: DateTime(2026, 10),
          rangeStart: start,
          rangeEnd: end,
          unavailableDates: widget.unavailableDates,
          onRangeChanged: (first, last) => setState(() {
            start = first;
            end = last;
          }),
        ),
      ),
    );
  }
}
