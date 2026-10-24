import 'package:flutter/material.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../constants/app_dimens.dart';
import '../../constants/app_strings.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../paw_avatar_image.dart';

class ChatModal extends StatefulWidget {
  final String ownerId;
  final String sitterId;
  final String sitterName;
  final String avatarPath;

  const ChatModal({
    super.key,
    required this.ownerId,
    required this.sitterId,
    this.sitterName = AppStrings.defaultWalkerName,
    this.avatarPath = AppStrings.defaultWalkerAvatar,
  });

  static Future<void> show(
    BuildContext context, {
    required String ownerId,
    required String sitterId,
    String sitterName = AppStrings.defaultWalkerName,
    String avatarPath = AppStrings.defaultWalkerAvatar,
  }) {
    final pawTheme = context.pawTheme;
    return showDialog<void>(
      context: context,
      barrierColor: pawTheme.modalBarrier,
      builder: (_) => ChatModal(
        ownerId: ownerId,
        sitterId: sitterId,
        sitterName: sitterName,
        avatarPath: avatarPath,
      ),
    );
  }

  @override
  State<ChatModal> createState() => _ChatModalState();
}

class _ChatModalState extends State<ChatModal> {
  final SettingsRepository _settingsRepository = const SettingsRepository();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late UserRole _activeRole;
  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _activeRole = _settingsRepository.getUserRole();
    _messages = _readMessages();
  }

  bool get _canAccessConversation => _activeRole == UserRole.sitter
      ? _settingsRepository.getActiveSitterId() == widget.sitterId
      : _settingsRepository.getOwnerId() == widget.ownerId;

  @override
  void didUpdateWidget(covariant ChatModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    _activeRole = _settingsRepository.getUserRole();
    _messages = _readMessages();
    if (oldWidget.ownerId != widget.ownerId ||
        oldWidget.sitterId != widget.sitterId ||
        !_canAccessConversation) {
      _textController.clear();
    }
  }

  List<ChatMessage> _readMessages() {
    if (!_canAccessConversation) return <ChatMessage>[];
    return _settingsRepository
        .getChatMessages(ownerId: widget.ownerId, sitterId: widget.sitterId)
        .map((message) {
          final senderRole =
              message.senderRole ??
              (message.isMe ? UserRole.owner : UserRole.sitter);
          return message.copyWith(isMe: senderRole == _activeRole);
        })
        .toList();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    _activeRole = _settingsRepository.getUserRole();
    if (!_canAccessConversation) {
      _textController.clear();
      setState(() => _messages = <ChatMessage>[]);
      return;
    }
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final ownerId = widget.ownerId;
    final sitterId = widget.sitterId;
    final now = DateTime.now();
    final msg = ChatMessage(
      id: 'msg_${now.microsecondsSinceEpoch}',
      senderName: _activeRole == UserRole.sitter
          ? _settingsRepository.getSitterName()
          : _settingsRepository.getOwnerName(),
      text: text,
      time:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      isMe: _activeRole == UserRole.owner,
      senderRole: _activeRole,
    );

    await _settingsRepository.addChatMessage(
      msg,
      ownerId: ownerId,
      sitterId: sitterId,
    );
    if (!mounted || widget.ownerId != ownerId || widget.sitterId != sitterId) {
      return;
    }
    _activeRole = _settingsRepository.getUserRole();
    _textController.clear();
    setState(() {
      _messages = _readMessages();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  BoxDecoration _dialogDecoration(
    ColorScheme colors,
    PawThemeExtension pawTheme,
  ) {
    return BoxDecoration(
      color: pawTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppDimens.modalRadius),
      boxShadow: pawTheme.floatingShadow,
      border: Border.all(
        color: colors.outlineVariant.withValues(alpha: AppDimens.alphaMedium),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    return Dialog(
      backgroundColor: pawTheme.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMd,
        vertical: AppDimens.paddingLg,
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: AppDimens.maxShellWidth,
          maxHeight: AppDimens.chatModalMaxHeight,
        ),
        decoration: _dialogDecoration(colors, pawTheme),
        child: _ChatModalContent(
          sitterName: widget.sitterName,
          avatarPath: widget.avatarPath,
          messages: _messages,
          scrollController: _scrollController,
          textController: _textController,
          onSend: _canAccessConversation ? _sendMessage : null,
        ),
      ),
    );
  }
}

class _ChatModalContent extends StatelessWidget {
  final String sitterName;
  final String avatarPath;
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final TextEditingController textController;
  final VoidCallback? onSend;

  const _ChatModalContent({
    required this.sitterName,
    required this.avatarPath,
    required this.messages,
    required this.scrollController,
    required this.textController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: <Widget>[
        _ChatHeader(sitterName: sitterName, avatarPath: avatarPath),
        Divider(height: AppDimens.dividerThin, color: colors.outlineVariant),
        Expanded(
          child: _ChatMessageList(
            messages: messages,
            scrollController: scrollController,
          ),
        ),
        Divider(height: AppDimens.dividerThin, color: colors.outlineVariant),
        _ChatInputBar(controller: textController, onSend: onSend),
      ],
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final String sitterName;
  final String avatarPath;

  const _ChatHeader({required this.sitterName, required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingLg),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: AppDimens.avatarRadiusMd,
            backgroundImage: PawImageProvider.resolve(avatarPath),
          ),
          const SizedBox(width: AppDimens.p12),
          Expanded(child: _ChatSitterOnlineStatus(sitterName: sitterName)),
          IconButton(
            icon: Icon(Icons.close, color: colors.onSurfaceVariant),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: pawTheme.surfaceContainerLow,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatSitterOnlineStatus extends StatelessWidget {
  final String sitterName;

  const _ChatSitterOnlineStatus({required this.sitterName});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(sitterName, style: textTheme.titleMedium),
        Row(
          children: <Widget>[
            Container(
              width: AppDimens.dotMd,
              height: AppDimens.dotMd,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: pawTheme.success,
              ),
            ),
            const SizedBox(width: AppDimens.p6),
            Expanded(
              child: Text(
                AppStrings.chatOnlineSubtitle,
                style: textTheme.bodySmall?.copyWith(color: colors.secondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;

  const _ChatMessageList({
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(AppDimens.p18),
      itemCount: messages.length,
      itemBuilder: (context, index) => _ChatBubble(message: messages[index]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  BorderRadius _resolveBubbleRadius() {
    return BorderRadius.circular(AppDimens.radiusXl).copyWith(
      bottomRight: message.isMe
          ? const Radius.circular(AppDimens.radiusXxs)
          : const Radius.circular(AppDimens.radiusXl),
      bottomLeft: !message.isMe
          ? const Radius.circular(AppDimens.radiusXxs)
          : const Radius.circular(AppDimens.radiusXl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;

    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.p6),
        constraints: const BoxConstraints(
          maxWidth: AppDimens.chatBubbleMaxWidth,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.p16,
          vertical: AppDimens.p12,
        ),
        decoration: BoxDecoration(
          color: message.isMe
              ? colors.primaryContainer
              : pawTheme.surfaceContainerLow,
          borderRadius: _resolveBubbleRadius(),
        ),
        child: _ChatBubbleTextContent(
          message: message,
          textTheme: textTheme,
          colors: colors,
          pawTheme: pawTheme,
        ),
      ),
    );
  }
}

class _ChatBubbleTextContent extends StatelessWidget {
  final ChatMessage message;
  final TextTheme textTheme;
  final ColorScheme colors;
  final PawThemeExtension pawTheme;

  const _ChatBubbleTextContent({
    required this.message,
    required this.textTheme,
    required this.colors,
    required this.pawTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          message.text,
          style: textTheme.bodyMedium?.copyWith(
            color: message.isMe ? pawTheme.pureWhite : colors.onSurface,
          ),
        ),
        const SizedBox(height: AppDimens.p4),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            message.time,
            style: AppTypography.toMicroTag(
              textTheme.labelSmall!,
              color: message.isMe
                  ? colors.onPrimaryContainer
                  : colors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;

  const _ChatInputBar({required this.controller, required this.onSend});

  InputDecoration _inputDecoration(
    PawThemeExtension pawTheme,
    TextTheme textTheme,
  ) {
    return InputDecoration(
      hintText: AppStrings.chatInputHint,
      hintStyle: textTheme.bodyMedium,
      filled: true,
      fillColor: pawTheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.heroCardRadius),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pawTheme = context.pawTheme;
    final textTheme = context.pawTextTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p16,
        vertical: AppDimens.p12,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              enabled: onSend != null,
              onSubmitted: onSend == null ? null : (_) => onSend!(),
              decoration: _inputDecoration(pawTheme, textTheme),
            ),
          ),
          const SizedBox(width: AppDimens.p10),
          Container(
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.send_rounded,
                color: colors.onPrimary,
                size: AppDimens.iconMd,
              ),
              onPressed: onSend,
            ),
          ),
        ],
      ),
    );
  }
}
