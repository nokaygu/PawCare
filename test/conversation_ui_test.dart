import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paw_care/core/theme/app_theme.dart';
import 'package:paw_care/core/widgets/modals/chat_modal.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';

void main() {
  const settings = SettingsRepository();
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  testWidgets('Two owners share a sitter without sharing conversations', (
    tester,
  ) async {
    const sitterId = 'shared_sitter';
    final ownerA = await settings.activateOwner(
      email: 'owner_a@example.com',
      name: 'Sahip A',
    );
    await settings.setUserRole(UserRole.owner);
    await _mountChat(tester, ownerA, sitterId);
    await _send(tester, 'A kişisinin mesajı');

    final ownerB = await settings.activateOwner(
      email: 'owner_b@example.com',
      name: 'Sahip B',
    );
    expect(ownerB, isNot(ownerA));
    await _mountChat(tester, ownerB, sitterId);
    expect(find.text('A kişisinin mesajı'), findsNothing);
    await _send(tester, 'B kişisinin mesajı');

    await settings.setUserRole(UserRole.sitter);
    await settings.setActiveSitterId(sitterId);
    await settings.setSitterName('Ortak Bakıcı');
    await _mountChat(tester, ownerA, sitterId);
    expect(find.text('A kişisinin mesajı'), findsOneWidget);
    expect(find.text('B kişisinin mesajı'), findsNothing);
    expect(_alignment(tester, 'A kişisinin mesajı'), Alignment.centerLeft);
    await _send(tester, 'A kişisine yanıt');

    await _mountChat(tester, ownerB, sitterId);
    expect(find.text('B kişisinin mesajı'), findsOneWidget);
    expect(find.text('A kişisine yanıt'), findsNothing);
    await _send(tester, 'B kişisine yanıt');

    await settings.activateOwner(email: 'owner_a@example.com');
    await settings.setUserRole(UserRole.owner);
    await _mountChat(tester, ownerA, sitterId);
    expect(find.text('A kişisine yanıt'), findsOneWidget);
    expect(find.text('B kişisine yanıt'), findsNothing);
    expect(_alignment(tester, 'A kişisinin mesajı'), Alignment.centerRight);
    expect(_alignment(tester, 'A kişisine yanıt'), Alignment.centerLeft);
    expect(
      settings
          .getChatMessages(ownerId: ownerA, sitterId: sitterId)
          .map((message) => message.senderName),
      <String>['Sahip A', 'Ortak Bakıcı'],
    );
    expect(
      settings
          .getChatMessages(ownerId: ownerB, sitterId: sitterId)
          .map((message) => message.senderName),
      <String>['Sahip B', 'Ortak Bakıcı'],
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('One owner has separate threads with identically named sitters', (
    tester,
  ) async {
    final ownerId = await settings.activateOwner(
      email: 'one_owner@example.com',
      name: 'Köpek Sahibi',
    );
    await settings.setUserRole(UserRole.owner);
    await _mountChat(tester, ownerId, 'sitter_a');
    await _send(tester, 'İlk bakıcıya mesaj');
    await tester.enterText(find.byType(TextField), 'Gönderilmemiş taslak');

    await _mountChat(tester, ownerId, 'sitter_b');
    expect(find.text('İlk bakıcıya mesaj'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await _send(tester, 'İkinci bakıcıya mesaj');

    await _mountChat(tester, ownerId, 'sitter_a');
    expect(find.text('İlk bakıcıya mesaj'), findsOneWidget);
    expect(find.text('İkinci bakıcıya mesaj'), findsNothing);
    expect(
      settings
          .getChatMessages(ownerId: ownerId, sitterId: 'sitter_a')
          .single
          .text,
      'İlk bakıcıya mesaj',
    );
    expect(
      settings
          .getChatMessages(ownerId: ownerId, sitterId: 'sitter_b')
          .single
          .text,
      'İkinci bakıcıya mesaj',
    );
  });

  testWidgets('Renaming participants preserves their shared conversation', (
    tester,
  ) async {
    const sitterId = 'rename_sitter';
    final ownerId = await settings.activateOwner(
      email: 'before_rename@example.com',
      name: 'İlk Sahip Adı',
    );
    await settings.setUserRole(UserRole.owner);
    await _mountChat(tester, ownerId, sitterId);
    await _send(tester, 'Ad değişmeden önce');

    await settings.setUserName('Yeni Sahip Adı');
    await settings.setUserEmail('after_rename@example.com');
    await _mountChat(tester, ownerId, sitterId, contactName: 'Yeni Bakıcı Adı');
    expect(settings.getOwnerId(), ownerId);
    expect(find.text('Ad değişmeden önce'), findsOneWidget);
    await _send(tester, 'Ad değiştikten sonra');

    await settings.setSitterName('Yeni Bakıcı Adı');
    await settings.setUserRole(UserRole.sitter);
    await settings.setActiveSitterId(sitterId);
    await _mountChat(tester, ownerId, sitterId, contactName: 'Yeni Sahip Adı');
    expect(find.text('Ad değişmeden önce'), findsOneWidget);
    expect(find.text('Ad değiştikten sonra'), findsOneWidget);
    await _send(tester, 'Bakıcıdan yeni yanıt');

    final messages = settings.getChatMessages(
      ownerId: ownerId,
      sitterId: sitterId,
    );
    expect(messages.map((message) => message.senderName), <String>[
      'İlk Sahip Adı',
      'Yeni Sahip Adı',
      'Yeni Bakıcı Adı',
    ]);
    expect(messages.map((message) => message.senderRole), <UserRole>[
      UserRole.owner,
      UserRole.owner,
      UserRole.sitter,
    ]);
    expect(_alignment(tester, 'Bakıcıdan yeni yanıt'), Alignment.centerRight);
  });

  testWidgets('An owner cannot read or send in another owner conversation', (
    tester,
  ) async {
    const sitterId = 'protected_sitter';
    final ownerA = await settings.activateOwner(
      email: 'protected_a@example.com',
      name: 'Sahip A',
    );
    await settings.setUserRole(UserRole.owner);
    await _mountChat(tester, ownerA, sitterId);
    await _send(tester, 'A kişisinin özel mesajı');
    await tester.enterText(find.byType(TextField), 'Başkasının adına gönderme');
    final oldSend = tester
        .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send_rounded))
        .onPressed!;

    final ownerB = await settings.activateOwner(
      email: 'protected_b@example.com',
      name: 'Sahip B',
    );
    oldSend();
    await tester.pumpAndSettle();
    expect(find.text('A kişisinin özel mesajı'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.send_rounded),
          )
          .onPressed,
      isNull,
    );
    expect(
      settings.getChatMessages(ownerId: ownerA, sitterId: sitterId),
      hasLength(1),
    );
    expect(
      settings.getChatMessages(ownerId: ownerB, sitterId: sitterId),
      isEmpty,
    );
  });

  testWidgets('A sitter cannot read or send in another sitter conversation', (
    tester,
  ) async {
    const sitterA = 'protected_sitter_a';
    const sitterB = 'protected_sitter_b';
    final ownerId = await settings.activateOwner(
      email: 'protected_owner@example.com',
      name: 'Köpek Sahibi',
    );
    await settings.setUserRole(UserRole.sitter);
    await settings.setActiveSitterId(sitterA);
    await settings.setSitterName('Bakıcı A');
    await _mountChat(tester, ownerId, sitterA);
    await _send(tester, 'A bakıcısının özel mesajı');
    await tester.enterText(
      find.byType(TextField),
      'Başka bakıcı adına gönderme',
    );
    final oldSend = tester
        .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send_rounded))
        .onPressed!;

    await settings.setActiveSitterId(sitterB);
    await settings.setSitterName('Bakıcı B');
    oldSend();
    await tester.pumpAndSettle();
    expect(find.text('A bakıcısının özel mesajı'), findsNothing);
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.send_rounded),
          )
          .onPressed,
      isNull,
    );
    expect(
      settings.getChatMessages(ownerId: ownerId, sitterId: sitterA),
      hasLength(1),
    );
    expect(
      settings.getChatMessages(ownerId: ownerId, sitterId: sitterB),
      isEmpty,
    );
  });
}

Future<void> _mountChat(
  WidgetTester tester,
  String ownerId,
  String sitterId, {
  String contactName = 'Aynı Görünen Ad',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: ChatModal(
          ownerId: ownerId,
          sitterId: sitterId,
          sitterName: contactName,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _send(WidgetTester tester, String message) async {
  await tester.enterText(find.byType(TextField), message);
  await tester.tap(find.byIcon(Icons.send_rounded));
  await tester.pumpAndSettle();
}

AlignmentGeometry _alignment(WidgetTester tester, String message) {
  return tester
      .widget<Align>(
        find
            .ancestor(of: find.text(message), matching: find.byType(Align))
            .first,
      )
      .alignment;
}
