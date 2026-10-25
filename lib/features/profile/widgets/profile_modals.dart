import 'package:flutter/material.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../controller/profile_controller.dart';

class EditUserProfileModal extends StatefulWidget {
  final ProfileController controller;

  const EditUserProfileModal({super.key, required this.controller});

  static Future<void> show(
    BuildContext context, {
    required ProfileController controller,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) => EditUserProfileModal(controller: controller),
    );
  }

  @override
  State<EditUserProfileModal> createState() => _EditUserProfileModalState();
}

class _EditUserProfileModalState extends State<EditUserProfileModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.controller.activeDisplayName,
    );
    _emailCtrl = TextEditingController(
      text: widget.controller.activeDisplayEmail,
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await widget.controller.updateActiveUserProfile(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
      );
    } on ArgumentError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message == AppStrings.invalidEmail
                ? AppStrings.invalidEmail
                : AppStrings.profileEmailInUse,
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.accountUpdatedSnack)),
    );
  }

  List<Widget> _actions(ColorScheme colors, TextTheme textTheme) => <Widget>[
    TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Text(AppStrings.cancel, style: textTheme.bodyLarge),
    ),
    AsyncActionBuilder(
      action: _save,
      builder: (_, save, busy) => ElevatedButton(
        onPressed: save,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
        ),
        child: Text(busy ? AppStrings.saving : AppStrings.save),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return AlertDialog(
      backgroundColor: pawTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
      ),
      title: Text(
        AppStrings.editAccountModalTitle,
        style: textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.fullNameLabel,
            ),
          ),
          const SizedBox(height: AppDimens.p12),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(
              labelText: AppStrings.emailAddressLabel,
            ),
          ),
        ],
      ),
      actions: _actions(colors, textTheme),
    );
  }
}

class ProfileInfoModal extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const ProfileInfoModal({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  static Future<void> showPaymentMethods(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) => const ProfileInfoModal(
        title: AppStrings.paymentMethodsTitle,
        icon: Icons.credit_card_outlined,
        items: AppStrings.paymentModalItems,
      ),
    );
  }

  static Future<void> showPrivacySecurity(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) => const ProfileInfoModal(
        title: AppStrings.privacyAndSecurityTitle,
        icon: Icons.security_outlined,
        items: AppStrings.privacyModalItems,
      ),
    );
  }

  static Future<void> showHelpSupport(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierColor: context.pawTheme.modalBarrier,
      builder: (_) => const ProfileInfoModal(
        title: AppStrings.helpAndSupportTitle,
        icon: Icons.help_outline,
        items: AppStrings.helpModalItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return AlertDialog(
      backgroundColor: pawTheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
      ),
      title: Row(
        children: <Widget>[
          Icon(icon, color: colors.primary, size: AppDimens.iconLg),
          const SizedBox(width: AppDimens.p8),
          Expanded(child: Text(title, style: textTheme.titleLarge)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.p8),
                child: Text(line, style: textTheme.bodyMedium),
              ),
            )
            .toList(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(AppStrings.ok),
        ),
      ],
    );
  }
}
