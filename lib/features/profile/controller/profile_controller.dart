import 'package:flutter/foundation.dart';

import '../../../app/router/app_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/lifecycle_notifier.dart';
import '../../../data/local/hive_boxes.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../data/repositories/sitter_repository.dart';

class ProfileController extends LifecycleNotifier<int> {
  final AppRouter router;
  final ThemeController themeController;
  final SettingsRepository _settingsRepository;
  final SitterRepository _sitterRepository;
  final VoidCallback? onProfileChanged;
  late String _ownerName, _ownerEmail, _sitterName, _sitterEmail;
  String? _avatarPath;
  late int _sessionRevision;

  ProfileController({
    required this.router,
    required this.themeController,
    SettingsRepository? settingsRepository,
    SitterRepository? sitterRepository,
    this.onProfileChanged,
  }) : _settingsRepository = settingsRepository ?? const SettingsRepository(),
       _sitterRepository = sitterRepository ?? const SitterRepository(),
       super(0) {
    _sessionRevision = router.value.sessionRevision;
    _refreshSnapshot();
    router.addListener(_syncSession);
  }

  void _syncSession() {
    if (_sessionRevision == router.value.sessionRevision) return;
    _sessionRevision = router.value.sessionRevision;
    notifyProfileChanged();
  }

  void _refreshSnapshot() {
    _ownerName = _settingsRepository.getUserName();
    _ownerEmail = _settingsRepository.getUserEmail();
    _sitterName = _settingsRepository.getSitterName();
    _sitterEmail = _settingsRepository.getSitterEmail();
    _avatarPath = _sitterRepository
        .getById(_settingsRepository.getActiveSitterId())
        ?.imagePath;
  }

  @override
  void dispose() {
    router.removeListener(_syncSession);
    super.dispose();
  }

  UserRole get role => router.role;

  String get ownerName => _ownerName;
  String get ownerEmail => _ownerEmail;
  String get sitterName => _sitterName;
  String get sitterEmail => _sitterEmail;

  String get activeDisplayName =>
      role == UserRole.owner ? ownerName : sitterName;

  String get activeDisplayEmail =>
      role == UserRole.owner ? ownerEmail : sitterEmail;

  String? get activeAvatarPath => role == UserRole.sitter ? _avatarPath : null;

  void notifyProfileChanged() {
    if (isDisposed) return;
    _refreshSnapshot();
    value = value + 1;
  }

  Future<void> updateActiveUserProfile({
    required String name,
    required String email,
  }) async {
    final targetRole = role;
    final targetId = targetRole == UserRole.owner
        ? _settingsRepository.getOwnerId()
        : _settingsRepository.getActiveSitterId();
    await runExclusive(
      () => HiveBoxes.runLocked('account_session', () async {
        final currentId = targetRole == UserRole.owner
            ? _settingsRepository.getOwnerId()
            : _settingsRepository.getActiveSitterId();
        if (isDisposed || role != targetRole || targetId != currentId) {
          throw StateError('Account changed');
        }
        final cleanName = name.trim();
        final cleanEmail = email.trim();
        if (cleanEmail.isNotEmpty) {
          _settingsRepository.validateProfileEmail(
            cleanEmail,
            targetRole,
            targetId,
          );
        }
        if (targetRole == UserRole.owner) {
          await _settingsRepository.updateOwnerProfile(
            ownerId: targetId,
            name: cleanName.isEmpty ? null : cleanName,
            email: cleanEmail.isEmpty ? null : cleanEmail,
          );
        } else {
          if (cleanName.isNotEmpty) {
            await _sitterRepository.updateSitterName(targetId, cleanName);
          }
          await _settingsRepository.updateSitterProfile(
            sitterId: targetId,
            name: cleanName.isEmpty ? null : cleanName,
            email: cleanEmail.isEmpty ? null : cleanEmail,
          );
        }
        if (isDisposed) return;
        notifyProfileChanged();
        onProfileChanged?.call();
      }),
    );
  }

  Future<void> toggleRole() async {
    final nextRole = router.role == UserRole.owner
        ? UserRole.sitter
        : UserRole.owner;
    await router.setRole(nextRole);
    if (!isDisposed) notifyProfileChanged();
  }

  void openWelcomeScreen() {
    router.showWelcome();
  }
}
