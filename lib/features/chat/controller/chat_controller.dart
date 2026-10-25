import '../../../core/utils/lifecycle_notifier.dart';
import '../../../core/utils/record_id.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/conversation_repository.dart';
import '../../../data/repositories/settings_repository.dart';

class ChatState {
  final List<ChatMessage> messages;
  final int? before;
  final bool loading;
  final bool failed;
  final bool olderPage;
  ChatState({
    List<ChatMessage> messages = const [],
    this.before,
    this.loading = false,
    this.failed = false,
    this.olderPage = false,
  }) : messages = List.unmodifiable(messages);
}

class ChatController extends LifecycleNotifier<ChatState> {
  final String ownerId;
  final String sitterId;
  final UserRole role;
  final SettingsRepository settings;
  final ConversationRepository repository;
  ChatMessage? _pendingMessage;
  ChatController({
    required this.ownerId,
    required this.sitterId,
    this.settings = const SettingsRepository(),
    this.repository = const ConversationRepository(),
  }) : role = settings.getUserRole(),
       super(ChatState(loading: true));
  bool get canAccess =>
      settings.getUserRole() == role &&
      (role == UserRole.owner
          ? settings.getOwnerId() == ownerId
          : settings.getActiveSitterId() == sitterId);
  ChatMessage _perspective(ChatMessage message) =>
      message.copyWith(isMe: message.senderRole == role);
  Future<void> load() => runExclusive(_loadLatest);
  Future<void> _loadLatest() async {
    if (!canAccess || isDisposed) {
      value = ChatState();
      return;
    }
    try {
      final page = await repository.readPage(
        ownerId: ownerId,
        sitterId: sitterId,
      );
      if (!canAccess || isDisposed) {
        value = ChatState();
        return;
      }
      value = ChatState(
        messages: page.messages.map(_perspective).toList(),
        before: page.before,
      );
    } catch (_) {
      value = ChatState(failed: true);
    }
  }

  Future<void> loadOlder() => runExclusive(() async {
    if (!canAccess || value.before == null) return;
    final previous = value;
    final page = await repository.readPage(
      ownerId: ownerId,
      sitterId: sitterId,
      before: previous.before,
    );
    if (!canAccess || isDisposed) return;
    value = ChatState(
      messages: page.messages.map(_perspective).toList(),
      before: page.before,
      olderPage: true,
    );
  });
  Future<void> send(String text) => runExclusive(() async {
    if (!canAccess) {
      value = ChatState();
      throw StateError('Account changed');
    }
    final clean = text.trim();
    if (clean.isEmpty) return;
    final now = DateTime.now();
    if (_pendingMessage?.text != clean) {
      _pendingMessage = ChatMessage(
        id: RecordId.create('msg'),
        text: clean,
        senderName: role == UserRole.owner
            ? settings.getOwnerName()
            : settings.getSitterName(),
        senderRole: role,
        isMe: role == UserRole.owner,
        time:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      );
    }
    final message = _pendingMessage!;
    await repository.addMessage(message, ownerId: ownerId, sitterId: sitterId);
    _pendingMessage = null;
    if (!canAccess || isDisposed) {
      value = ChatState();
      return;
    }
    // Keep a bounded recent window after send; older history stays accessible.
    await _loadLatest();
  });
}
