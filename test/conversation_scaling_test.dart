import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/core/constants/app_strings.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/conversation_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';
import 'package:paw_care/features/chat/controller/chat_controller.dart';
import 'package:paw_care/features/chat/view/chat_modal.dart';

ChatMessage _message(String id) => ChatMessage(
  id: id,
  senderName: 'Owner',
  text: id,
  time: '12:00',
  isMe: true,
  senderRole: UserRole.owner,
);

class _Reads extends ConversationRepository {
  int reads = 0;
  @override
  Future<MessagePage> readPage({
    required String ownerId,
    required String sitterId,
    int? before,
    int limit = 50,
  }) {
    reads++;
    return super.readPage(
      ownerId: ownerId,
      sitterId: sitterId,
      before: before,
      limit: limit,
    );
  }
}

class _FirstSendFails extends ConversationRepository {
  final gate = Completer<void>();
  final ids = <String>[];
  @override
  Future<void> addMessage(
    ChatMessage message, {
    required String ownerId,
    required String sitterId,
  }) async {
    ids.add(message.id);
    if (ids.length == 1) {
      await gate.future;
      throw StateError('Disk');
    }
    await super.addMessage(message, ownerId: ownerId, sitterId: sitterId);
  }
}

Widget _chat(ChatController controller, {String name = 'Contact'}) =>
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: ChatModal(
          ownerId: controller.ownerId,
          sitterId: controller.sitterId,
          controller: controller,
          sitterName: name,
        ),
      ),
    );
void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);
  test('Ten thousand stored messages use lazy bodies and one append writes one body without rewriting history', () async {
    final directory = await Directory.systemTemp.createTemp(
      'pawcare_chat_scale_',
    );
    try {
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      final owner = const SettingsRepository().getOwnerId();
      const sitter = 'scale';
      final key = ConversationRepository.conversationKey(
        ownerId: owner,
        sitterId: sitter,
      );
      final bodies = Hive.lazyBox<dynamic>(HiveBoxes.messagesBoxName);
      for (var start = 0; start < 10000; start += 200) {
        await bodies.putAll({
          for (var i = start; i < start + 200; i++)
            '$key/$i': _message('message_$i').toMap(),
        });
      }
      await HiveBoxes.putValue(HiveBoxes.conversationsBoxName, key, {
        'count': 10000,
      });
      final first = await bodies.get('$key/0');
      final settingsRevision = HiveBoxes.revision(HiveBoxes.settingsBoxName);
      final events = <BoxEvent>[];
      final subscription = bodies.watch().listen(events.add);
      const repository = ConversationRepository();
      await repository.addMessage(
        _message('last'),
        ownerId: owner,
        sitterId: sitter,
      );
      await Future<void>.delayed(Duration.zero);
      expect(events, hasLength(1));
      expect(events.single.key, '$key/10000');
      expect(await bodies.get('$key/0'), first);
      expect(HiveBoxes.revision(HiveBoxes.settingsBoxName), settingsRevision);
      final page = await repository.readPage(ownerId: owner, sitterId: sitter);
      expect(page.messages, hasLength(50));
      expect(page.messages.last.id, 'last');
      expect(page.before, 9951);
      final controller = ChatController(ownerId: owner, sitterId: sitter);
      await controller.load();
      await controller.loadOlder();
      expect(controller.value.messages, hasLength(50));
      expect(controller.value.messages.last.id, 'message_9950');
      controller.dispose();
      await subscription.cancel();
      expect(bodies, isA<LazyBox<dynamic>>());
      expect(
        Hive.lazyBox<dynamic>(HiveBoxes.archiveBoxName),
        isA<LazyBox<dynamic>>(),
      );
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
  test(
    'An interrupted body/metadata append is recovered idempotently',
    () async {
      final owner = const SettingsRepository().getOwnerId();
      const sitter = 'partial';
      final key = ConversationRepository.conversationKey(
        ownerId: owner,
        sitterId: sitter,
      );
      final message = _message('same_id');
      await HiveBoxes.putValue(
        HiveBoxes.messagesBoxName,
        '$key/0',
        message.toMap(),
      );
      const repository = ConversationRepository();
      await repository.addMessage(message, ownerId: owner, sitterId: sitter);
      await repository.addMessage(message, ownerId: owner, sitterId: sitter);
      expect(
        await repository.readAll(ownerId: owner, sitterId: sitter),
        hasLength(1),
      );
    },
  );
  test('Explicit archive preserves messages while the active thread stays empty and accepts new messages', () async {
    const repository = ConversationRepository();
    final owner = const SettingsRepository().getOwnerId();
    const sitter = 'archive';
    final key = ConversationRepository.conversationKey(
      ownerId: owner,
      sitterId: sitter,
    );
    await repository.addMessage(
      _message('old'),
      ownerId: owner,
      sitterId: sitter,
    );
    await repository.archiveConversation(ownerId: owner, sitterId: sitter);
    expect(await repository.readAll(ownerId: owner, sitterId: sitter), isEmpty);
    expect(
      (await HiveBoxes.getHistoryValue(
        HiveBoxes.archiveBoxName,
        'message/$key/0',
      ))['id'],
      'old',
    );
    await repository.addMessage(
      _message('new'),
      ownerId: owner,
      sitterId: sitter,
    );
    expect(
      (await repository.readAll(ownerId: owner, sitterId: sitter)).single.id,
      'new',
    );
  });
  testWidgets('Rebuilding the same conversation does not reload its history', (
    tester,
  ) async {
    final repository = _Reads();
    final controller = ChatController(
      ownerId: const SettingsRepository().getOwnerId(),
      sitterId: 'same',
      repository: repository,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(_chat(controller));
    await tester.pumpAndSettle();
    expect(repository.reads, 1);
    await tester.pumpWidget(_chat(controller, name: 'Renamed'));
    await tester.pumpAndSettle();
    expect(repository.reads, 1);
  });
  testWidgets(
    'Failed chat send keeps the draft, disables duplicate sends and reuses its identity on retry',
    (tester) async {
      final repository = _FirstSendFails();
      final controller = ChatController(
        ownerId: const SettingsRepository().getOwnerId(),
        sitterId: 'failure',
        repository: repository,
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(_chat(controller));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Draft');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.send_rounded),
            )
            .onPressed,
        isNull,
      );
      expect(repository.ids, hasLength(1));
      repository.gate.complete();
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Draft',
      );
      expect(find.text(AppStrings.bookingSaveFailed), findsOneWidget);
      ScaffoldMessenger.of(tester.element(find.byType(ChatModal)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      expect(repository.ids, hasLength(2));
      expect(repository.ids.toSet(), hasLength(1));
      expect(controller.value.messages, hasLength(1));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    },
  );
  testWidgets(
    'Chat opens at the latest message and older history remains reachable in bounded pages',
    (tester) async {
      final owner = const SettingsRepository().getOwnerId();
      const sitter = 'pages';
      const repository = ConversationRepository();
      for (var i = 0; i < 120; i++) {
        await repository.addMessage(
          _message('message_$i'),
          ownerId: owner,
          sitterId: sitter,
        );
      }
      final controller = ChatController(ownerId: owner, sitterId: sitter);
      addTearDown(controller.dispose);
      await tester.pumpWidget(_chat(controller));
      await tester.pumpAndSettle();
      expect(find.text('message_119'), findsOneWidget);
      expect(find.text('message_0'), findsNothing);
      await controller.loadOlder();
      await tester.pumpAndSettle();
      expect(controller.value.messages, hasLength(50));
      expect(controller.value.messages.last.id, 'message_69');
      expect(find.text(AppStrings.recentMessages), findsOneWidget);
      await tester.tap(find.text(AppStrings.recentMessages));
      await tester.pumpAndSettle();
      expect(controller.value.messages.last.id, 'message_119');
    },
  );
}
