import 'calendar_date.dart';
import 'models.dart';

enum HealthSummaryKind { noRecords, unknownDates, overdue, upcoming, completed }

class HealthSummary {
  final HealthSummaryKind kind;
  final Vaccination? primary;
  final int overdueCount;
  final DateTime evaluatedAt;
  const HealthSummary({
    required this.kind,
    required this.evaluatedAt,
    this.primary,
    this.overdueCount = 0,
  });

  factory HealthSummary.forDog(Dog? dog, DateTime now) {
    final records = dog?.vaccinations ?? <Vaccination>[];
    if (records.isEmpty) {
      return HealthSummary(kind: HealthSummaryKind.noRecords, evaluatedAt: now);
    }
    final open = records
        .where((v) => v.status != VaccineStatus.completed)
        .toList();
    if (open.isEmpty) {
      return HealthSummary(kind: HealthSummaryKind.completed, evaluatedAt: now);
    }
    final known = open.where((v) => v.dueAt != null).toList()
      ..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    final overdue = known
        .where((v) => v.statusAt(now) == VaccineStatus.overdue)
        .toList();
    if (overdue.isNotEmpty) {
      return HealthSummary(
        kind: HealthSummaryKind.overdue,
        evaluatedAt: now,
        primary: overdue.first,
        overdueCount: overdue.length,
      );
    }
    final unknown = open.where((v) => v.dueAt == null).firstOrNull;
    if (unknown != null) {
      return HealthSummary(
        kind: HealthSummaryKind.unknownDates,
        evaluatedAt: now,
        primary: unknown,
      );
    }
    return HealthSummary(
      kind: HealthSummaryKind.upcoming,
      evaluatedAt: now,
      primary: known.first,
    );
  }

  int? get daysUntil {
    final due = primary?.dueAt;
    if (due == null) return null;
    final now = CalendarDate.day(evaluatedAt);
    return DateTime.utc(
      due.year,
      due.month,
      due.day,
    ).difference(DateTime.utc(now.year, now.month, now.day)).inDays;
  }
}
