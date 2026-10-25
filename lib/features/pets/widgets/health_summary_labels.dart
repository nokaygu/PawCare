import '../../../core/constants/app_strings.dart';
import '../../../data/models/health_summary.dart';

extension HealthSummaryLabels on HealthSummary {
  String get title => switch (kind) {
    HealthSummaryKind.noRecords => AppStrings.noHealthRecordsTitle,
    HealthSummaryKind.unknownDates => AppStrings.unknownVaccineDateTitle,
    HealthSummaryKind.overdue => AppStrings.overdueVaccineTitle(primary!.title),
    HealthSummaryKind.upcoming => AppStrings.vaccineTimeTitle(primary!.title),
    HealthSummaryKind.completed => AppStrings.allVaccinesCompletedTitle,
  };

  String get subtitle => switch (kind) {
    HealthSummaryKind.noRecords => AppStrings.noHealthRecordsBody,
    HealthSummaryKind.unknownDates => AppStrings.unknownVaccineDateBody,
    HealthSummaryKind.completed => AppStrings.noUpcomingVaccineSubtitle,
    _ => AppStrings.vaccineAppointmentSubtitle(
      primary!.dueDate,
      primary!.vetName.isEmpty ? AppStrings.notProvided : primary!.vetName,
    ),
  };

  String get timing => daysUntil == null
      ? AppStrings.dateUnknown
      : AppStrings.vaccineDays(daysUntil!);
}
