import 'dart:math';

/// IDs do not depend on the clock's precision or on the number of writers.
abstract final class RecordId {
  static String create(String prefix, {DateTime? at}) {
    final random = Random.secure();
    final suffix = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${prefix}_${(at ?? DateTime.now()).microsecondsSinceEpoch}_$suffix';
  }
}
