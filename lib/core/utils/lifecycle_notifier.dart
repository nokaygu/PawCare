import 'package:flutter/foundation.dart';

/// An async completion may persist data, but must not notify a closed view.
class LifecycleNotifier<T> extends ValueNotifier<T> {
  LifecycleNotifier(super.value);

  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  Future<R> runExclusive<R>(Future<R> Function() action) async {
    if (_isDisposed || _isBusy) throw StateError('Operation unavailable');
    _isBusy = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  @override
  set value(T newValue) {
    if (!_isDisposed) super.value = newValue;
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    super.dispose();
  }
}
