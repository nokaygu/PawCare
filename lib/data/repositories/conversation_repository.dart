import '../../core/constants/app_limits.dart';
import '../local/hive_boxes.dart';
import '../models/models.dart';

class MessagePage {
  final List<ChatMessage> messages;
  final int? before;
  MessagePage(List<ChatMessage> messages, this.before)
    : messages = List.unmodifiable(messages);
}

class ConversationRepository {
  const ConversationRepository();
  static String conversationKey({
    required String ownerId,
    required String sitterId,
  }) => ConversationIdentity.key(ownerId: ownerId, sitterId: sitterId);

  int _count(String thread) {
    final meta = HiveBoxes.getValue(HiveBoxes.conversationsBoxName, thread);
    return meta is Map && meta['count'] is int ? meta['count'] as int : 0;
  }

  Future<MessagePage> readPage({
    required String ownerId,
    required String sitterId,
    int? before,
    int limit = AppLimits.messagePageSize,
  }) async {
    if (limit < 1 || limit > AppLimits.messagePageSize) {
      throw ArgumentError.value(limit);
    }
    final thread = conversationKey(ownerId: ownerId, sitterId: sitterId);
    final end = (before ?? _count(thread)).clamp(0, _count(thread));
    final start = (end - limit).clamp(0, end);
    final messages = <ChatMessage>[];
    for (var i = start; i < end; i++) {
      final raw = await HiveBoxes.getHistoryValue(
        HiveBoxes.messagesBoxName,
        '$thread/$i',
      );
      if (raw is Map) {
        try {
          messages.add(ChatMessage.fromMap(raw));
        } catch (_) {
          /* Original stays in history storage. */
        }
      }
    }
    return MessagePage(messages, start == 0 ? null : start);
  }

  /// Explicit export/inspection path; the chat screen uses bounded readPage.
  Future<List<ChatMessage>> readAll({
    required String ownerId,
    required String sitterId,
  }) async {
    final pages = <List<ChatMessage>>[];
    int? before;
    do {
      final page = await readPage(
        ownerId: ownerId,
        sitterId: sitterId,
        before: before,
      );
      pages.add(page.messages);
      before = page.before;
    } while (before != null);
    return List.unmodifiable(pages.reversed.expand((page) => page));
  }

  Future<void> archiveConversation({
    required String ownerId,
    required String sitterId,
  }) {
    final thread = conversationKey(ownerId: ownerId, sitterId: sitterId);
    return HiveBoxes.runLocked('conversation_$thread', () async {
      final count = _count(thread);
      for (var i = 0; i < count; i++) {
        final raw = await HiveBoxes.getHistoryValue(
          HiveBoxes.messagesBoxName,
          '$thread/$i',
        );
        if (raw == null) continue;
        await HiveBoxes.putValue(
          HiveBoxes.archiveBoxName,
          'message/$thread/$i',
          raw,
        );
        await HiveBoxes.deleteValue(HiveBoxes.messagesBoxName, '$thread/$i');
      }
      await HiveBoxes.putValue(HiveBoxes.conversationsBoxName, thread, {
        'count': 0,
      });
    });
  }

  Future<void> addMessage(
    ChatMessage message, {
    required String ownerId,
    required String sitterId,
  }) {
    final thread = conversationKey(ownerId: ownerId, sitterId: sitterId);
    return HiveBoxes.runLocked('conversation_$thread', () async {
      var count = _count(thread);
      final meta = HiveBoxes.getValue(HiveBoxes.conversationsBoxName, thread);
      if (meta is Map && meta['lastMessageId'] == message.id) return;
      // Recover a body persisted just before an interrupted metadata write.
      while (true) {
        final existing = await HiveBoxes.getHistoryValue(
          HiveBoxes.messagesBoxName,
          '$thread/$count',
        );
        if (existing == null) break;
        count++;
        if (existing is Map && existing['id'] == message.id) {
          await HiveBoxes.putValue(HiveBoxes.conversationsBoxName, thread, {
            'count': count,
            'lastMessageId': message.id,
          });
          return;
        }
      }
      await HiveBoxes.putValue(
        HiveBoxes.messagesBoxName,
        '$thread/$count',
        message.toMap(),
      );
      await HiveBoxes.putValue(HiveBoxes.conversationsBoxName, thread, {
        'count': count + 1,
        'lastMessageId': message.id,
      });
    });
  }
}
