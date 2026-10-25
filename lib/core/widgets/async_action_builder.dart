import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

Future<bool> performUiAction(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
  String? Function()? warning,
}) async {
  try {
    await action();
    final message = warning?.call() ?? successMessage;
    if (context.mounted && message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
    return true;
  } catch (error) {
    if (context.mounted) {
      final message = error is ArgumentError && error.message is String
          ? error.message as String
          : AppStrings.bookingSaveFailed;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
    return false;
  }
}

class AsyncActionBuilder extends StatefulWidget {
  final Future<void> Function() action;
  final Widget Function(BuildContext, VoidCallback?, bool) builder;
  const AsyncActionBuilder({
    super.key,
    required this.action,
    required this.builder,
  });

  @override
  State<AsyncActionBuilder> createState() => _AsyncActionBuilderState();
}

class _AsyncActionBuilderState extends State<AsyncActionBuilder> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    await performUiAction(context, widget.action);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _busy ? null : _run, _busy);
}
