final RegExp _recordSequence = RegExp(r'(\d+)$');
final RegExp _timestampedId = RegExp(r'_(\d+)_[0-9a-f]{32}$');

int compareNewestRecordIds(String first, String second) {
  final firstDigits =
      _timestampedId.firstMatch(first)?.group(1) ??
      _recordSequence.firstMatch(first)?.group(1);
  final secondDigits =
      _timestampedId.firstMatch(second)?.group(1) ??
      _recordSequence.firstMatch(second)?.group(1);
  final firstNumber = firstDigits == null ? null : BigInt.tryParse(firstDigits);
  final secondNumber = secondDigits == null
      ? null
      : BigInt.tryParse(secondDigits);
  if (firstNumber != null && secondNumber != null) {
    final comparison = secondNumber.compareTo(firstNumber);
    if (comparison != 0) return comparison;
  } else if (firstNumber != null || secondNumber != null) {
    return firstNumber == null ? 1 : -1;
  }
  return second.compareTo(first);
}
