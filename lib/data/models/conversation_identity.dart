abstract final class ConversationIdentity {
  static const String legacyOwnerId = 'owner_legacy';

  static String key({required String ownerId, required String sitterId}) {
    if (ownerId.trim().isEmpty || sitterId.trim().isEmpty) {
      throw ArgumentError('Conversation participants must have stable IDs.');
    }
    return 'conversation:${Uri.encodeComponent(ownerId)}:${Uri.encodeComponent(sitterId)}';
  }

  static String ownerIdForLegacyBooking({
    required String? ownerName,
    required String bookingId,
  }) {
    final normalizedName = (ownerName ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s.]+'), ' ')
        .trim();
    if (normalizedName == 'aygen' || normalizedName == 'aygen y') {
      return legacyOwnerId;
    }
    if (normalizedName.isNotEmpty) {
      return 'legacy_owner_name:${Uri.encodeComponent(normalizedName)}';
    }
    return 'legacy_owner_booking:${Uri.encodeComponent(bookingId)}';
  }
}
