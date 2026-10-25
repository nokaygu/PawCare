import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class UnreadNotificationsScope extends InheritedWidget {
  final ValueListenable<int> count;
  const UnreadNotificationsScope({
    super.key,
    required this.count,
    required super.child,
  });
  static ValueListenable<int>? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<UnreadNotificationsScope>()
      ?.count;
  @override
  bool updateShouldNotify(UnreadNotificationsScope oldWidget) =>
      count != oldWidget.count;
}
