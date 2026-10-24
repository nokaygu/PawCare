import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../controller/auth_controller.dart';
import '../widgets/auth_modal_header.dart';
import 'signup_modal.dart';

class LoginModal extends StatefulWidget {
  final AppRouter router;

  const LoginModal({super.key, required this.router});

  static Future<void> show(BuildContext context, {required AppRouter router}) {
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => LoginModal(router: router),
    );
  }

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  late final AuthController _authController;
  final TextEditingController _emailController = TextEditingController(
    text: 'aygen@pawcare.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '12345678',
  );
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(router: widget.router);
  }

  @override
  void dispose() {
    _authController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await _authController.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted || !ok) return;
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppStrings.loginSuccessSnack,
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
        constraints: const BoxConstraints(maxWidth: AppDimens.modalMaxWidthMd),
        decoration: _dialogDecoration(colors, pawTheme),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.p28),
          child: _LoginFormContent(
            authController: _authController,
            emailController: _emailController,
            passwordController: _passwordController,
            obscurePassword: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onSubmit: _submit,
            router: widget.router,
          ),
        ),
      ),
    );
  }
}

class _LoginFormContent extends StatelessWidget {
  final AuthController authController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final AppRouter router;

  const _LoginFormContent({
    required this.authController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.router,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AuthModalHeader(
          badgeLabel: AppStrings.authDemoBadge,
          title: AppStrings.loginWelcomeTitle,
          subtitle: AppStrings.loginWelcomeSubtitle,
        ),
        const SizedBox(height: AppDimens.p24),
        ValueListenableBuilder<String?>(
          valueListenable: authController,
          builder: (context, error, _) => error == null
              ? const SizedBox.shrink()
              : AuthErrorBanner(message: error),
        ),
        _LoginInputsSection(
          emailController: emailController,
          passwordController: passwordController,
          obscurePassword: obscurePassword,
          onToggleObscure: onToggleObscure,
        ),
        const SizedBox(height: AppDimens.p24),
        _LoginSubmitButton(onSubmit: onSubmit),
        const SizedBox(height: AppDimens.p18),
        _SwitchToSignUpButton(router: router),
      ],
    );
  }
}

class _LoginSubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const _LoginSubmitButton({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: AppDimens.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
        ),
        child: Text(
          AppStrings.loginButton,
          style: textTheme.titleMedium?.copyWith(color: colors.onPrimary),
        ),
      ),
    );
  }
}

class _LoginInputsSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;

  const _LoginInputsSection({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
  });

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required ColorScheme colors,
    required PawThemeExtension pawTheme,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: colors.secondary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: pawTheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildToggleIcon(ColorScheme colors) {
    return IconButton(
      icon: Icon(
        obscurePassword ? Icons.visibility_off : Icons.visibility,
        color: colors.onSurfaceVariant,
      ),
      onPressed: onToggleObscure,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppStrings.emailLabel, style: textTheme.bodyLarge),
        const SizedBox(height: AppDimens.p6),
        TextField(
          controller: emailController,
          decoration: _inputDecoration(
            hint: AppStrings.emailHint,
            icon: Icons.email_outlined,
            colors: colors,
            pawTheme: pawTheme,
          ),
        ),
        const SizedBox(height: AppDimens.p18),
        Text(AppStrings.passwordLabel, style: textTheme.bodyLarge),
        const SizedBox(height: AppDimens.p6),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: _inputDecoration(
            hint: AppStrings.passwordMaskedHint,
            icon: Icons.lock_outline,
            colors: colors,
            pawTheme: pawTheme,
            suffixIcon: _buildToggleIcon(colors),
          ),
        ),
      ],
    );
  }
}

class _SwitchToSignUpButton extends StatelessWidget {
  final AppRouter router;

  const _SwitchToSignUpButton({required this.router});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.pawTextTheme;

    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          SignUpModal.show(context, router: router);
        },
        child: RichText(
          text: TextSpan(
            text: AppStrings.noAccountPrefix,
            style: textTheme.bodyMedium,
            children: <InlineSpan>[
              TextSpan(
                text: AppStrings.createAccountButton,
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
