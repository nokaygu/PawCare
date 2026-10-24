import 'dart:math';

import '../../core/constants/app_strings.dart';
import '../local/hive_boxes.dart';
import '../local/hive_seed_data.dart';
import '../models/models.dart';

class SettingsRepository {
  const SettingsRepository();

  static const String _themeModeKey = 'is_dark_mode';
  static const String _roleKey = 'user_role';
  static const String _chatMessagesKeyPrefix = 'chat_messages_';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _sitterNameKey = 'sitter_user_name';
  static const String _sitterEmailKey = 'sitter_user_email';
  static const String _ownerIdKey = 'owner_id';
  static const String _ownerIdsByEmailKey = 'owner_ids_by_email';
  static const String _ownerProfilesKey = 'owner_profiles';
  static const String _activeSitterIdKey = 'active_sitter_id';
  static const String activeDogIdKey = 'active_dog_id';

  bool getIsDarkMode() {
    final val = HiveBoxes.getValue(
      HiveBoxes.settingsBoxName,
      _themeModeKey,
      defaultValue: false,
    );
    return val as bool? ?? false;
  }

  Future<void> setIsDarkMode(bool isDark) async {
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _themeModeKey, isDark);
  }

  UserRole getUserRole() {
    final roleName = HiveBoxes.getValue(
      HiveBoxes.settingsBoxName,
      _roleKey,
      defaultValue: UserRole.owner.name,
    ) as String?;
    return UserRole.values.firstWhere(
      (r) => r.name == roleName,
      orElse: () => UserRole.owner,
    );
  }

  Future<void> setUserRole(UserRole role) async {
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _roleKey, role.name);
  }

  String getUserName() {
    return HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          _userNameKey,
          defaultValue: AppStrings.defaultOwnerFullName,
        ) as String? ??
        AppStrings.defaultOwnerFullName;
  }

  String getOwnerName() => getUserName();

  Future<void> setUserName(String name) async {
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _userNameKey, name);
    await _storeOwnerProfile(getOwnerId(), name, getUserEmail());
  }

  String getUserEmail() {
    return HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          _userEmailKey,
          defaultValue: AppStrings.defaultOwnerEmail,
        ) as String? ??
        AppStrings.defaultOwnerEmail;
  }

  Future<void> setUserEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    final identities = _ownerIdsByEmail();
    final ownerId = getOwnerId();
    final existingOwner = identities[normalizedEmail];
    if (existingOwner != null && existingOwner != ownerId) {
      throw ArgumentError.value(email, 'email');
    }
    final previousEmail = getUserEmail().trim().toLowerCase();
    if (identities[previousEmail] == ownerId) {
      identities.remove(previousEmail);
    }
    identities[normalizedEmail] = ownerId;
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _ownerIdsByEmailKey,
      identities,
    );
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _userEmailKey, email);
    await _storeOwnerProfile(ownerId, getOwnerName(), email);
  }

  String getOwnerId() {
    return HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          _ownerIdKey,
          defaultValue: ConversationIdentity.legacyOwnerId,
        ) as String? ??
        ConversationIdentity.legacyOwnerId;
  }

  Map<String, dynamic> _ownerIdsByEmail() {
    final raw = HiveBoxes.getValue(
      HiveBoxes.settingsBoxName,
      _ownerIdsByEmailKey,
    );
    return raw is Map
        ? Map<String, dynamic>.from(raw)
        : <String, dynamic>{
            AppStrings.defaultOwnerEmail: ConversationIdentity.legacyOwnerId,
            getUserEmail().trim().toLowerCase(): getOwnerId(),
          };
  }

  Map<String, dynamic> _ownerProfiles() {
    final raw = HiveBoxes.getValue(
      HiveBoxes.settingsBoxName,
      _ownerProfilesKey,
    );
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  Future<void> _storeOwnerProfile(
    String ownerId,
    String name,
    String email,
  ) async {
    final profiles = _ownerProfiles();
    profiles[ownerId] = <String, dynamic>{'name': name, 'email': email};
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _ownerProfilesKey,
      profiles,
    );
  }

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
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _ownerIdsByEmailKey,
      identities,
    );
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _ownerProfilesKey,
      profiles,
    );
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _ownerIdKey, ownerId);
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _userNameKey,
      displayName,
    );
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _userEmailKey,
      email.trim(),
    );
    return ownerId;
  }

  String _newOwnerId() {
    final random = Random.secure();
    final suffix = List<int>.generate(
      16,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return 'owner_${DateTime.now().microsecondsSinceEpoch}_$suffix';
  }

  String getActiveSitterId() {
    return HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          _activeSitterIdKey,
          defaultValue: 'sitter_1',
        ) as String? ??
        'sitter_1';
  }

  Future<void> setActiveSitterId(String sitterId) async {
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _activeSitterIdKey,
      sitterId,
    );
  }

  String getSitterName() {
    return HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          _sitterNameKey,
          defaultValue: AppStrings.defaultSitterFullName,
        ) as String? ??
        AppStrings.defaultSitterFullName;
  }

  Future<void> setSitterName(String name) async {
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _sitterNameKey, name);
  }

  String getSitterEmail() {
    return HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          _sitterEmailKey,
          defaultValue: AppStrings.defaultSitterEmail,
        ) as String? ??
        AppStrings.defaultSitterEmail;
  }

  Future<void> setSitterEmail(String email) async {
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, _sitterEmailKey, email);
  }

  String getActiveDogId() {
    return HiveBoxes.getValue(
          HiveBoxes.settingsBoxName,
          activeDogIdKey,
          defaultValue: HiveSeedData.initialDog.id,
        ) as String? ??
        HiveSeedData.initialDog.id;
  }

  Future<void> setActiveDogId(String dogId) async {
    await HiveBoxes.putValue(HiveBoxes.settingsBoxName, activeDogIdKey, dogId);
  }

  String _chatMessagesKey(String contactKey) {
    if (contactKey.trim().isEmpty) {
      throw ArgumentError.value(contactKey, 'contactKey');
    }
    return '$_chatMessagesKeyPrefix$contactKey';
  }

  static String conversationKey({
    required String ownerId,
    required String sitterId,
  }) => ConversationIdentity.key(ownerId: ownerId, sitterId: sitterId);

  String _resolveConversationKey({
    String? contactKey,
    String? ownerId,
    String? sitterId,
  }) {
    if (ownerId != null && sitterId != null && contactKey == null) {
      return conversationKey(ownerId: ownerId, sitterId: sitterId);
    }
    if (contactKey != null && ownerId == null && sitterId == null) {
      return contactKey;
    }
    throw ArgumentError(
      'Provide both participant IDs or a legacy contact key.',
    );
  }

  List<ChatMessage> getChatMessages({
    String? contactKey,
    String? ownerId,
    String? sitterId,
  }) {
    final raw = HiveBoxes.getValue(
      HiveBoxes.settingsBoxName,
      _chatMessagesKey(
        _resolveConversationKey(
          contactKey: contactKey,
          ownerId: ownerId,
          sitterId: sitterId,
        ),
      ),
    ) as List<dynamic>?;
    if (raw == null || raw.isEmpty) {
      return <ChatMessage>[];
    }
    return raw
        .map((e) => ChatMessage.fromMap(Map<dynamic, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> addChatMessage(
    ChatMessage message, {
    String? contactKey,
    String? ownerId,
    String? sitterId,
  }) async {
    final key = _resolveConversationKey(
      contactKey: contactKey,
      ownerId: ownerId,
      sitterId: sitterId,
    );
    final current = getChatMessages(contactKey: key);
    final updated = <ChatMessage>[...current, message];
    await HiveBoxes.putValue(
      HiveBoxes.settingsBoxName,
      _chatMessagesKey(key),
      updated.map((m) => m.toMap()).toList(),
    );
  }
}
