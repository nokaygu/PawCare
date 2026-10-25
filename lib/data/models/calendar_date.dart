abstract final class CalendarDate {
  static String iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime? tryParse(String? text) {
    final value = (text ?? '').trim();
    final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (iso != null) {
      return _checked(
        int.parse(iso[1]!),
        int.parse(iso[2]!),
        int.parse(iso[3]!),
      );
    }
    return null;
  }

  static DateTime? _checked(int year, int month, int day) {
    if (year < 1900 || year > 2200) return null;
    final date = DateTime(year, month, day);
    return date.year == year && date.month == month && date.day == day
        ? date
        : null;
  }
}
