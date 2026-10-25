import '../../core/constants/app_strings.dart';

enum ServiceType {
  hotel,
  dayCare,
  walk;

  String get category => switch (this) {
    hotel => AppStrings.categoryHotel,
    dayCare => AppStrings.categoryDaycare,
    walk => AppStrings.categoryWalking,
  };

  String get unit => switch (this) {
    hotel => AppStrings.unitNight,
    dayCare => AppStrings.unitDay,
    walk => AppStrings.unitHour,
  };
}
