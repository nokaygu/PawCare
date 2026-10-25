abstract final class ConversationIdentity {
  static String key({required String ownerId, required String sitterId}) {
    if (ownerId.trim().isEmpty || sitterId.trim().isEmpty) {
      throw ArgumentError('Conversation participants must have stable IDs.');
    }
    return 'conversation:${Uri.encodeComponent(ownerId)}:${Uri.encodeComponent(sitterId)}';
  }
}
