import 'package:flutter/material.dart';

import '../../../data/models/models.dart';

import 'dart:async';

import '../controller/chat_controller.dart';
import '../../../core/widgets/async_action_builder.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/paw_avatar_image.dart';

class ChatModal extends StatefulWidget {
  final String ownerId;
  final String sitterId;
  final String sitterName;
  final String avatarPath;
  final ChatController? controller;

  const ChatModal({
    super.key,
    required this.ownerId,
    required this.sitterId,
    this.controller,
    this.sitterName = AppStrings.chatTitle,
    this.avatarPath = '',
  });

  static Future<void> show(
    BuildContext context, {
    required String ownerId,
    required String sitterId,
    String sitterName = AppStrings.chatTitle,
    String avatarPath = '',
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
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatController _controller;
  void _start() {
    _controller =
        widget.controller ??
        ChatController(ownerId: widget.ownerId, sitterId: widget.sitterId);
    unawaited(_controller.load());
  }

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant ChatModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId == widget.ownerId &&
        oldWidget.sitterId == widget.sitterId &&
        oldWidget.controller == widget.controller &&
        _controller.canAccess) {
      return;
    }
    if (oldWidget.controller == null) _controller.dispose();
    _textController.clear();
    _start();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _sendMessage() => performUiAction(context, () async {
    final controller = _controller;
    await controller.send(_textController.text);
    if (!mounted || !identical(controller, _controller)) return;
    _textController.clear();
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  });
  Future<bool> _older() => performUiAction(context, () async {
    await _controller.loadOlder();
    if (mounted && _scrollController.hasClients) _scrollController.jumpTo(0);
  });

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
        child: ValueListenableBuilder<ChatState>(
          valueListenable: _controller,
          builder: (context, state, _) => _ChatModalContent(
            sitterName: widget.sitterName,
            avatarPath: widget.avatarPath,
            messages: _controller.canAccess ? state.messages : const [],
            scrollController: _scrollController,
            textController: _textController,
            onSend: !_controller.isBusy && _controller.canAccess
                ? _sendMessage
                : null,
            onOlder: !_controller.isBusy && state.before != null
                ? _older
                : null,
            onLatest: !_controller.isBusy && (state.olderPage || state.failed)
                ? () => unawaited(_controller.load())
                : null,
            loading: state.loading,
          ),
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
  final VoidCallback? onOlder;
  final VoidCallback? onLatest;
  final bool loading;

  const _ChatModalContent({
    required this.sitterName,
    required this.avatarPath,
    required this.messages,
    required this.scrollController,
    required this.textController,
    required this.onSend,
    this.onOlder,
    this.onLatest,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: <Widget>[
        _ChatHeader(sitterName: sitterName, avatarPath: avatarPath),
        Divider(height: AppDimens.dividerThin, color: colors.outlineVariant),
        if (loading) const LinearProgressIndicator(),
        if (onLatest != null)
          TextButton(
            onPressed: onLatest,
            child: const Text(AppStrings.recentMessages),
          ),
        Expanded(
          child: _ChatMessageList(
            messages: messages,
            scrollController: scrollController,
            onOlder: onOlder,
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
            backgroundImage: PawImageProvider.avatar(
              context,
              avatarPath,
              radius: AppDimens.avatarRadiusMd,
            ),
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
  final VoidCallback? onOlder;

  const _ChatMessageList({
    required this.messages,
    required this.scrollController,
    this.onOlder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(AppDimens.p18),
      itemCount: messages.length + (onOlder == null ? 0 : 1),
      itemBuilder: (context, index) => index == messages.length
          ? TextButton(
              onPressed: onOlder,
              child: const Text(AppStrings.olderMessages),
            )
          : _ChatBubble(message: messages[messages.length - 1 - index]),
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
