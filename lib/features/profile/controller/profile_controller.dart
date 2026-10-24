import 'package:flutter/foundation.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';

class ProfileController extends ValueNotifier<int> {
  final AppRouter router;
  final ThemeController themeController;
  final SettingsRepository _settingsRepository;
  final SitterRepository _sitterRepository;
  final VoidCallback? onProfileChanged;

  ProfileController({
    required this.router,
    required this.themeController,
    SettingsRepository? settingsRepository,
    SitterRepository? sitterRepository,
    this.onProfileChanged,
  }) : _settingsRepository = settingsRepository ?? const SettingsRepository(),
       _sitterRepository = sitterRepository ?? const SitterRepository(),
       super(0);

  UserRole get role => router.role;

  String get ownerName => _settingsRepository.getUserName();
  String get ownerEmail => _settingsRepository.getUserEmail();
  String get sitterName => _settingsRepository.getSitterName();
  String get sitterEmail => _settingsRepository.getSitterEmail();

  String get activeDisplayName =>
      role == UserRole.owner ? ownerName : sitterName;

  String get activeDisplayEmail =>
      role == UserRole.owner ? ownerEmail : sitterEmail;

  String? get activeAvatarPath =>
      role == UserRole.sitter ? 'assets/images/ayse.jpg' : null;

  void notifyProfileChanged() {
    value = value + 1;
  }

  Future<void> updateActiveUserProfile({
    required String name,
    required String email,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim();
    if (role == UserRole.owner) {
      if (cleanEmail.isNotEmpty) {
        await _settingsRepository.setUserEmail(cleanEmail);
      }
      if (cleanName.isNotEmpty) {
        await _settingsRepository.setUserName(cleanName);
      }
    } else {
      if (cleanName.isNotEmpty) {
        await _sitterRepository.updateSitterName(
          _settingsRepository.getActiveSitterId(),
          cleanName,
        );
        await _settingsRepository.setSitterName(cleanName);
      }
      if (cleanEmail.isNotEmpty) {
        await _settingsRepository.setSitterEmail(cleanEmail);
      }
    }
    notifyProfileChanged();
    onProfileChanged?.call();
  }

  Future<void> toggleRole() async {
    final nextRole = router.role == UserRole.owner
        ? UserRole.sitter
        : UserRole.owner;
    await router.setRole(nextRole);
    notifyProfileChanged();
  }

  void openWelcomeScreen() {
    router.showWelcome();
  }
}
