import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/widgets/modals/chat_modal.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';

void main() {
  const repository = SettingsRepository();
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  testWidgets('Sitter messages retain sender identity and owner perspective', (
    tester,
  ) async {
    const sitterId = 'chat_widget_sender_test';
    final ownerId = repository.getOwnerId();
    const message = 'Sohbet rolü doğrulaması';
    await repository.setUserRole(UserRole.sitter);
    await repository.setActiveSitterId(sitterId);
    await repository.setSitterName('Test Bakıcı');
    await _mountChat(tester, sitterId);

    await tester.enterText(find.byType(TextField), message);
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    final saved = repository
        .getChatMessages(ownerId: ownerId, sitterId: sitterId)
        .single;
    expect(saved.senderName, 'Test Bakıcı');
    expect(saved.senderRole, UserRole.sitter);
    expect(_messageAlignment(tester, message), Alignment.centerRight);
    expect(
      repository.getChatMessages(
        ownerId: ownerId,
        sitterId: 'another_widget_contact',
      ),
      isEmpty,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await repository.setUserRole(UserRole.owner);
    await _mountChat(tester, sitterId);
    expect(find.text(message), findsOneWidget);
    expect(_messageAlignment(tester, message), Alignment.centerLeft);
  });

  testWidgets(
    'Closing chat while a send completes does not use disposed state',
    (tester) async {
      await repository.setUserRole(UserRole.owner);
      await _mountChat(tester, 'chat_widget_disposal_test');
      await tester.enterText(
        find.byType(TextField),
        'Pencere kapanırken mesaj',
      );

      final send = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.send_rounded),
      );
      send.onPressed!();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(
        repository
            .getChatMessages(
              ownerId: repository.getOwnerId(),
              sitterId: 'chat_widget_disposal_test',
            )
            .single
            .text,
        'Pencere kapanırken mesaj',
      );
    },
  );
}

Future<void> _mountChat(WidgetTester tester, String sitterId) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: ChatModal(
          ownerId: const SettingsRepository().getOwnerId(),
          sitterId: sitterId,
        ),
      ),
    ),
  );
  await tester.pump();
}

AlignmentGeometry _messageAlignment(WidgetTester tester, String message) {
  final alignment = find.ancestor(
    of: find.text(message),
    matching: find.byType(Align),
  );
  return tester.widget<Align>(alignment.first).alignment;
}
