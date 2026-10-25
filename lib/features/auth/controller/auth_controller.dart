import '../../../core/constants/app_strings.dart';
import '../../../core/utils/input_validation.dart';
import '../../../core/utils/lifecycle_notifier.dart';

import '../../../app/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';
import '../../../data/repositories/sitter_account_repository.dart';

class AuthController extends LifecycleNotifier<String?> {
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
    return runExclusive(
      () => HiveBoxes.runLocked('account_session', () async {
        if (isDisposed) return false;
        if (email.trim().isEmpty || password.trim().isEmpty) {
          value = AppStrings.authErrorEmptyFields;
          return false;
        }
        value = null;
        if (!InputValidation.isEmail(email) || password.length < 8) {
          value = AppStrings.invalidAuthFields;
          return false;
        }
        final accounts = SitterAccountRepository(
          settings: _settingsRepository,
          sitters: _sitterRepository,
        );
        if (accounts.findByEmail(email) != null) {
          await accounts.activate(email: email);
          if (isDisposed) return false;
          await router.setRole(UserRole.sitter);
          if (isDisposed) return false;
          router.setSitterNavIndex(0);
        } else {
          await _settingsRepository.activateOwner(email: email.trim());
          if (isDisposed) return false;
          await router.setRole(UserRole.owner);
          if (isDisposed) return false;
          router.setOwnerNavIndex(0);
        }
        return true;
      }),
    );
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    required UserRole role,
  }) async {
    return runExclusive(
      () => HiveBoxes.runLocked('account_session', () async {
        if (isDisposed) return false;
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
        if (!InputValidation.isEmail(email) || password.length < 8) {
          value = AppStrings.invalidAuthFields;
          return false;
        }
        final accounts = SitterAccountRepository(
          settings: _settingsRepository,
          sitters: _sitterRepository,
        );
        if ((role == UserRole.owner && accounts.findByEmail(email) != null) ||
            (role == UserRole.sitter &&
                _settingsRepository.findOwnerIdByEmail(email) != null)) {
          value = AppStrings.profileEmailInUse;
          return false;
        }
        if (role == UserRole.owner) {
          await _settingsRepository.activateOwner(
            email: email.trim(),
            name: name.trim(),
          );
          if (isDisposed) return false;
          await router.setRole(role);
          if (isDisposed) return false;
          router.setOwnerNavIndex(0);
        } else {
          await SitterAccountRepository(
            settings: _settingsRepository,
            sitters: _sitterRepository,
          ).activate(email: email, name: name);
          if (isDisposed) return false;
          await router.setRole(role);
          if (isDisposed) return false;
          router.setSitterNavIndex(0);
        }
        return true;
      }),
    );
  }
}
