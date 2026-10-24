import 'package:flutter/foundation.dart';

import '../../../core/constants/app_strings.dart';

import '../../../app/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';

class AuthController extends ValueNotifier<String?> {
  final AppRouter router;
  final SettingsRepository _settingsRepository;
  final SitterRepository _sitterRepository;

  AuthController({
    required this.router,
    SettingsRepository? settingsRepository,
    SitterRepository? sitterRepository,
  }) : _settingsRepository = settingsRepository ?? const SettingsRepository(),
       _sitterRepository = sitterRepository ?? const SitterRepository(),
       super(null);

  void clearError() {
    value = null;
  }

  Future<bool> login({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      value = AppStrings.authErrorEmptyFields;
      return false;
    }
    value = null;
    await _settingsRepository.activateOwner(email: email.trim());
    await router.setRole(UserRole.owner);
    router.setOwnerNavIndex(0);
    return true;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required UserRole role,
  }) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      value = AppStrings.authErrorEmptyFields;
      return false;
    }
    if (password != confirmPassword) {
      value = AppStrings.authErrorPasswordMismatch;
      return false;
    }
    value = null;
    if (role == UserRole.owner) {
      await _settingsRepository.activateOwner(
        email: email.trim(),
        name: name.trim(),
      );
      await router.setRole(role);
      router.setOwnerNavIndex(0);
    } else {
      await _sitterRepository.updateSitterName(
        _settingsRepository.getActiveSitterId(),
        name.trim(),
      );
      await _settingsRepository.setSitterName(name.trim());
      await _settingsRepository.setSitterEmail(email.trim());
      await router.setRole(role);
      router.setSitterNavIndex(0);
    }
    return true;
  }
}
