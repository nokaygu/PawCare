abstract final class Money {
  static int cents(num amount) {
    final value = amount.toDouble();
    if (!value.isFinite || value.abs() > 1000000000) {
      throw ArgumentError.value(amount, 'amount');
    }
    return (value * 100).round();
  }

  static String format(num amount) {
    final value = cents(amount);
    final sign = value < 0 ? '-' : '';
    final absolute = value.abs();
    final fraction = absolute % 100;
    return '$sign₺${absolute ~/ 100}${fraction == 0 ? '' : ',${fraction.toString().padLeft(2, '0')}'}';
  }

  static String input(num amount) {
    final value = cents(amount);
    return '${value ~/ 100},${(value.abs() % 100).toString().padLeft(2, '0')}';
  }

  static double? parse(String text) {
    final trimmed = text.trim();
    final normalized = trimmed.contains(',')
        ? trimmed.replaceAll('.', '').replaceAll(',', '.')
        : trimmed;
    final value = double.tryParse(normalized);
    return value != null && value.isFinite ? value : null;
  }
}
