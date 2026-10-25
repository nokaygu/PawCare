import '../../core/constants/app_strings.dart';
import '../../core/utils/input_validation.dart';
import '../../core/utils/record_id.dart';
import '../local/hive_boxes.dart';
import '../models/models.dart';

class SettingsRepository {
  const SettingsRepository();

  static const String _themeModeKey = 'is_dark_mode';
  static const String _roleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _ownerIdKey = 'owner_id';
  static const String _ownerIdsByEmailKey = 'owner_ids_by_email';
  static const String _ownerProfilesKey = 'owner_profiles';
  static const String _activeSitterIdKey = 'active_sitter_id';
  static const String activeDogIdKey = 'active_dog_id';

  bool getIsDarkMode() =>
      HiveBoxes.getValue(HiveBoxes.settingsBoxName, _themeModeKey) as bool;

  Future<void> setIsDarkMode(bool isDark) async {
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _themeModeKey, isDark);
  }

  UserRole getUserRole() => UserRole.values.byName(
    HiveBoxes.getValue(HiveBoxes.settingsBoxName, _roleKey) as String,
  );

  bool get hasCompletedWelcome =>
      HiveBoxes.getValue(HiveBoxes.settingsBoxName, 'welcome_completed') ==
      true;

  Future<void> setUserRole(UserRole role) async {
    await HiveBoxes.putValues(HiveBoxes.settingsBoxName, {
      _roleKey: role.name,
      'welcome_completed': true,
    });
  }

  String getUserName() =>
      HiveBoxes.getValue(HiveBoxes.settingsBoxName, _userNameKey) as String;

  String getOwnerName() => getUserName();

  Future<void> setUserName(String name) =>
      updateOwnerProfile(ownerId: getOwnerId(), name: name);

  String getUserEmail() =>
      HiveBoxes.getValue(HiveBoxes.settingsBoxName, _userEmailKey) as String;

  Future<void> setUserEmail(String email) =>
      updateOwnerProfile(ownerId: getOwnerId(), email: email);

  void validateProfileEmail(String email, UserRole role, String identity) {
    if (!InputValidation.isEmail(email)) {
      throw ArgumentError(AppStrings.invalidEmail);
    }
    final normalized = email.trim().toLowerCase();
    final own = role == UserRole.owner
        ? _ownerIdsByEmail()
        : sitterIdsByEmail();
    final other = role == UserRole.owner
        ? sitterIdsByEmail()
        : _ownerIdsByEmail();
    if ((own[normalized] != null && own[normalized] != identity) ||
        other.containsKey(normalized)) {
      throw ArgumentError.value(email, 'email');
    }
  }

  Future<void> updateOwnerProfile({
    required String ownerId,
    String? name,
    String? email,
  }) async {
    if (getOwnerId() != ownerId) throw StateError('Account changed');
    final nextName = name ?? getOwnerName();
    final nextEmail = email?.trim() ?? getUserEmail();
    validateProfileEmail(nextEmail, UserRole.owner, ownerId);
    final identities = _ownerIdsByEmail()
      ..removeWhere((_, id) => id == ownerId);
    identities[nextEmail.toLowerCase()] = ownerId;
    final profiles = _ownerProfiles();
    profiles[ownerId] = <String, dynamic>{'name': nextName, 'email': nextEmail};
    await HiveBoxes.putValues(HiveBoxes.settingsBoxName, {
      _ownerIdsByEmailKey: identities,
      _ownerProfilesKey: profiles,
      _userNameKey: nextName,
      _userEmailKey: nextEmail,
    });
  }

  String getOwnerId() =>
      HiveBoxes.getValue(HiveBoxes.settingsBoxName, _ownerIdKey) as String;

  Map<String, dynamic> _ownerIdsByEmail() => Map<String, dynamic>.from(
    HiveBoxes.getValue(HiveBoxes.settingsBoxName, _ownerIdsByEmailKey) as Map,
  );

  String? findOwnerIdByEmail(String email) =>
      _ownerIdsByEmail()[email.trim().toLowerCase()] as String?;

  Map<String, dynamic> _ownerProfiles() => Map<String, dynamic>.from(
    HiveBoxes.getValue(HiveBoxes.settingsBoxName, _ownerProfilesKey) as Map,
  );

  Future<String> activateOwner({required String email, String? name}) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) throw ArgumentError.value(email, 'email');
    final identities = _ownerIdsByEmail();
    final profiles = _ownerProfiles();
    profiles[getOwnerId()] = <String, dynamic>{
      'name': getOwnerName(),
      'email': getUserEmail(),
    };
    final ownerId = identities[normalizedEmail] as String? ?? _newOwnerId();
    identities[normalizedEmail] = ownerId;
    final previousProfile = profiles[ownerId] as Map?;
    final displayName = name?.trim().isNotEmpty == true
        ? name!.trim()
        : previousProfile?['name'] as String? ??
              normalizedEmail.split('@').first;
    profiles[ownerId] = <String, dynamic>{
      'name': displayName,
      'email': email.trim(),
    };
    await HiveBoxes.putValues(HiveBoxes.settingsBoxName, {
      _ownerIdsByEmailKey: identities,
      _ownerProfilesKey: profiles,
      _ownerIdKey: ownerId,
      _userNameKey: displayName,
      _userEmailKey: email.trim(),
    });
    return ownerId;
  }

  String _newOwnerId() => RecordId.create('owner');

  String getActiveSitterId() =>
      HiveBoxes.getValue(HiveBoxes.settingsBoxName, _activeSitterIdKey)
          as String;

  Future<void> setActiveSitterId(String sitterId) async {
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _activeSitterIdKey,
      sitterId,
    );
  }

  String getSitterName() => _sitterProfile()['name'] as String;

  Future<void> setSitterName(String name) =>
      updateSitterProfile(sitterId: getActiveSitterId(), name: name);

  String getSitterEmail() => _sitterProfile()['email'] as String;

  Future<void> setSitterEmail(String email) =>
      updateSitterProfile(sitterId: getActiveSitterId(), email: email);

  Future<void> updateSitterProfile({
    required String sitterId,
    String? name,
    String? email,
  }) async {
    if (getActiveSitterId() != sitterId) throw StateError('Account changed');
    final nextName = name ?? getSitterName();
    final nextEmail = email?.trim() ?? getSitterEmail();
    if (email != null) {
      validateProfileEmail(nextEmail, UserRole.sitter, sitterId);
    }
    final identities = sitterIdsByEmail();
    if (email != null) {
      identities.removeWhere((_, id) => id == sitterId);
      identities[nextEmail.toLowerCase()] = sitterId;
    }
    await HiveBoxes.putValues(HiveBoxes.settingsBoxName, {
      'sitter_ids_by_email': identities,
      'sitter_profile_$sitterId': <String, dynamic>{
        'name': nextName,
        'email': nextEmail,
      },
    });
  }

  Future<void> activateSitter({
    required String sitterId,
    required String name,
    required String email,
  }) async {
    validateProfileEmail(email, UserRole.sitter, sitterId);
    final previousId = getActiveSitterId();
    final identities = sitterIdsByEmail()
      ..removeWhere((_, id) => id == sitterId);
    identities[email.trim().toLowerCase()] = sitterId;
    await HiveBoxes.putValues(HiveBoxes.settingsBoxName, {
      if (previousId != sitterId)
        'sitter_profile_$previousId': <String, dynamic>{
          'name': getSitterName(),
          'email': getSitterEmail(),
        },
      'sitter_profile_$sitterId': <String, dynamic>{
        'name': name,
        'email': email.trim(),
      },
      'sitter_ids_by_email': identities,
      _activeSitterIdKey: sitterId,
    });
  }

  Map<String, dynamic> sitterIdsByEmail() => Map<String, dynamic>.from(
    HiveBoxes.getValue(HiveBoxes.settingsBoxName, 'sitter_ids_by_email') as Map,
  );

  Map<String, dynamic> _sitterProfile() => Map<String, dynamic>.from(
    HiveBoxes.getValue(
      HiveBoxes.settingsBoxName,
      'sitter_profile_${getActiveSitterId()}',
    ) as Map,
  );

  String getActiveDogId() => HiveBoxes.getValue(
    HiveBoxes.settingsBoxName,
    '${activeDogIdKey}_${getOwnerId()}',
    defaultValue: '',
  ) as String;

  Future<void> setActiveDogId(String dogId) async {
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      '${activeDogIdKey}_${getOwnerId()}',
      dogId,
    );
  }
}
