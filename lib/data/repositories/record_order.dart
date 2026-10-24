final RegExp _recordSequence = RegExp(r'(\d+)$');

int compareNewestRecordIds(String first, String second) {
  final firstDigits = _recordSequence.firstMatch(first)?.group(1);
  final secondDigits = _recordSequence.firstMatch(second)?.group(1);
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
