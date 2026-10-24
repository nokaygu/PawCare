import 'dart:ui';

import 'package:flutter/material.dart';

import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

class CallModal extends StatelessWidget {
  final String contactName;
  final String roleSubtitle;
  final String phoneNumber;

  const CallModal({
    super.key,
    required this.contactName,
    required this.roleSubtitle,
    required this.phoneNumber,
  });

  static Future<void> show(
    BuildContext context, {
    required String contactName,
    required String roleSubtitle,
    required String phoneNumber,
  }) {
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => CallModal(
        contactName: contactName,
        roleSubtitle: roleSubtitle,
        phoneNumber: phoneNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDimens.modalBlurSigma,
        sigmaY: AppDimens.modalBlurSigma,
      ),
      child: Dialog(
        backgroundColor: pawTheme.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingXl,
          vertical: AppDimens.paddingXl,
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppDimens.modalMaxWidthSm,
          ),
          decoration: BoxDecoration(
            color: pawTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
            boxShadow: pawTheme.floatingShadow,
            border: Border.all(
              color: colors.outlineVariant.withValues(
                alpha: AppDimens.alphaMedium,
              ),
            ),
          ),
          padding: const EdgeInsets.all(AppDimens.paddingXl),
          child: _CallDialogBody(
            contactName: contactName,
            roleSubtitle: roleSubtitle,
            phoneNumber: phoneNumber,
          ),
        ),
      ),
    );
  }
}

class _CallDialogBody extends StatelessWidget {
  final String contactName;
  final String roleSubtitle;
  final String phoneNumber;

  const _CallDialogBody({
    required this.contactName,
    required this.roleSubtitle,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const _CallTopIconBadge(),
        const SizedBox(height: AppDimens.p16),
        Text(AppStrings.phoneCallTitle, style: textTheme.titleLarge),
        const SizedBox(height: AppDimens.p6),
        Text(
          contactName,
          style: AppTypography.toBold(textTheme.bodyLarge!),
          textAlign: TextAlign.center,
        ),
        Text(
          roleSubtitle,
          style: textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.p12),
        _PhoneNumberChip(phoneNumber: phoneNumber),
        const SizedBox(height: AppDimens.p16),
        Text(
          AppStrings.demoCallDisclaimer,
          style: textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimens.p24),
        _CallActionButtons(contactName: contactName, phoneNumber: phoneNumber),
      ],
    );
  }
}

class _CallTopIconBadge extends StatelessWidget {
  const _CallTopIconBadge();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: AppDimens.avatarBoxMd,
      height: AppDimens.avatarBoxMd,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.phone_in_talk,
        color: colors.primary,
        size: AppDimens.iconXxl,
      ),
    );
  }
}

class _PhoneNumberChip extends StatelessWidget {
  final String phoneNumber;

  const _PhoneNumberChip({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p8,
      ),
      decoration: BoxDecoration(
        color: pawTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Text(
        phoneNumber,
        style: textTheme.titleMedium?.copyWith(color: colors.primary),
      ),
    );
  }
}

class _CallActionButtons extends StatelessWidget {
  final String contactName;
  final String phoneNumber;

  const _CallActionButtons({
    required this.contactName,
    required this.phoneNumber,
  });

  void _startDemoCall(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.callingContactSnack(contactName, phoneNumber),
          style: textTheme.bodyLarge?.copyWith(color: colors.onPrimary),
        ),
        backgroundColor: colors.primary,
      ),
    );
  }

  ButtonStyle _buttonStyle({Color? bg, Color? fg, BorderSide? side}) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      side: side,
      elevation: AppDimens.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppDimens.p14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: _buttonStyle(side: BorderSide(color: colors.outlineVariant)),
            child: Text(AppStrings.cancel, style: textTheme.bodyLarge),
          ),
        ),
        const SizedBox(width: AppDimens.p12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _startDemoCall(context),
            style: _buttonStyle(bg: colors.primary, fg: colors.onPrimary),
            child: Text(
              AppStrings.callActionButton,
              style: AppTypography.toBold(
                textTheme.bodyLarge!,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
