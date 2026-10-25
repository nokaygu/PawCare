import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/models.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_modal_header.dart';
import 'login_modal.dart';

class SignUpModal extends StatefulWidget {
  final AppRouter router;

  const SignUpModal({super.key, required this.router});

  static Future<void> show(BuildContext context, {required AppRouter router}) {
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => SignUpModal(router: router),
    );
  }

  @override
  State<SignUpModal> createState() => _SignUpModalState();
}

class _SignUpModalState extends State<SignUpModal> {
  late final AuthController _authController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  UserRole _selectedRole = UserRole.owner;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(router: widget.router);
  }

  @override
  void dispose() {
    _authController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await _authController.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      role: _selectedRole,
    );
    if (!mounted || !ok) return;
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.signUpSuccessSnack,
          style: textTheme.bodyLarge?.copyWith(color: colors.onPrimary),
        ),
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),
    );
  }

  BoxDecoration _dialogDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.modalRadius),
      boxShadow: pawTheme.floatingShadow,
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Dialog(
      backgroundColor: pawTheme.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingLg,
        vertical: AppDimens.paddingXl,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: AppDimens.modalMaxWidthLg),
        decoration: _dialogDecoration(colors, pawTheme),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.p28),
          child: _SignUpBody(
            authController: _authController,
            selectedRole: _selectedRole,
            onRoleChanged: (r) => setState(() => _selectedRole = r),
            nameController: _nameController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            onSubmit: _submit,
            router: widget.router,
          ),
        ),
      ),
    );
  }
}

class _SignUpBody extends StatelessWidget {
  final AuthController authController;
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final Future<void> Function() onSubmit;
  final AppRouter router;

  const _SignUpBody({
    required this.authController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = context.pawTextTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AuthModalHeader(
          badgeLabel: AppStrings.signUpBadge,
          title: AppStrings.signUpTitle,
          subtitle: AppStrings.signUpSubtitle,
        ),
        const SizedBox(height: AppDimens.p20),
        ValueListenableBuilder<String?>(
          valueListenable: authController,
          builder: (context, error, _) => error == null
              ? const SizedBox.shrink()
              : AuthErrorBanner(message: error),
        ),
        Text(AppStrings.selectAccountRole, style: textTheme.bodyLarge),
        const SizedBox(height: AppDimens.p8),
        _SignUpRoleSelector(
          selectedRole: selectedRole,
          onRoleChanged: onRoleChanged,
        ),
        const SizedBox(height: AppDimens.p18),
        _SignUpFieldsGroup(
          nameController: nameController,
          emailController: emailController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
        ),
        const SizedBox(height: AppDimens.p24),
        _SignUpSubmitButton(onSubmit: onSubmit),
        const SizedBox(height: AppDimens.p16),
        _SwitchToLoginButton(router: router),
      ],
    );
  }
}

class _SignUpSubmitButton extends StatelessWidget {
  final Future<void> Function() onSubmit;

  const _SignUpSubmitButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: AsyncActionBuilder(
        action: onSubmit,
        builder: (_, run, busy) => ElevatedButton(
          onPressed: run,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: AppDimens.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            ),
          ),
          child: Text(
            busy ? AppStrings.saving : AppStrings.createAccountButton,
            style: textTheme.titleMedium?.copyWith(color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _SignUpRoleSelector extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const _SignUpRoleSelector({
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _RoleOptionBox(
            label: AppStrings.roleOwner,
            icon: Icons.pets,
            isSelected: selectedRole == UserRole.owner,
            onTap: () => onRoleChanged(UserRole.owner),
          ),
        ),
        const SizedBox(width: AppDimens.p12),
        Expanded(
          child: _RoleOptionBox(
            label: AppStrings.roleSitter,
            icon: Icons.home_work_outlined,
            isSelected: selectedRole == UserRole.sitter,
            onTap: () => onRoleChanged(UserRole.sitter),
          ),
        ),
      ],
    );
  }
}

class _RoleOptionBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOptionBox({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  BoxDecoration _boxDecoration(ColorScheme colors, PawThemeExtension pawTheme) {
    return BoxDecoration(
      color: isSelected
          ? colors.secondaryContainer
          : pawTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      border: Border.all(
        color: isSelected
            ? colors.primary
            : colors.outlineVariant.withValues(alpha: AppDimens.alphaMedium),
        width: isSelected
            ? AppDimens.borderWidthThick
            : AppDimens.borderWidthThin,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppDimens.p14,
          horizontal: AppDimens.p12,
        ),
        decoration: _boxDecoration(colors, pawTheme),
        child: Column(
          children: <Widget>[
            Icon(icon, color: isSelected ? colors.primary : colors.secondary),
            const SizedBox(height: AppDimens.p6),
            Text(
              label,
              style: isSelected
                  ? AppTypography.toBold(
                      textTheme.bodyLarge!,
                      color: colors.primary,
                    )
                  : AppTypography.toMedium(
                      textTheme.bodyLarge!,
                      color: colors.onSurfaceVariant,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignUpFieldsGroup extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const _SignUpFieldsGroup({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _LabeledInput(
          label: AppStrings.fullNameLabel,
          hint: AppStrings.fullNameHint,
          icon: Icons.person_outline,
          controller: nameController,
        ),
        const SizedBox(height: AppDimens.p14),
        _LabeledInput(
          label: AppStrings.emailLabel,
          hint: AppStrings.emailHint,
          icon: Icons.email_outlined,
          controller: emailController,
        ),
        const SizedBox(height: AppDimens.p14),
        _LabeledInput(
          label: AppStrings.passwordLabel,
          hint: AppStrings.passwordMinLengthHint,
          icon: Icons.lock_outline,
          controller: passwordController,
          obscure: true,
        ),
        const SizedBox(height: AppDimens.p14),
        _LabeledInput(
          label: AppStrings.confirmPasswordLabel,
          hint: AppStrings.confirmPasswordHint,
          icon: Icons.lock_outline,
          controller: confirmPasswordController,
          obscure: true,
        ),
      ],
    );
  }
}

class _LabeledInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;

  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: textTheme.bodyLarge),
        const SizedBox(height: AppDimens.p6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: colors.secondary),
            filled: true,
            fillColor: pawTheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusButton),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchToLoginButton extends StatelessWidget {
  final AppRouter router;

  const _SwitchToLoginButton({required this.router});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          LoginModal.show(context, router: router);
        },
        child: RichText(
          text: TextSpan(
            text: AppStrings.alreadyHaveAccountPrefix,
            style: textTheme.bodyMedium,
            children: <InlineSpan>[
              TextSpan(
                text: AppStrings.loginButton,
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
