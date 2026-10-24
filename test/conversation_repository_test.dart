import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';

const _settings = SettingsRepository();

ChatMessage _message(String id) => ChatMessage(
  id: id,
  senderName: 'Same display name',
  text: id,
  time: '12:00',
  isMe: true,
  senderRole: UserRole.owner,
);

Future<void> _withHive(Future<void> Function(Directory directory) action) async {
  final directory = await Directory.systemTemp.createTemp('pawcare_identity_');
  try {
    Hive.init(directory.path);
    await action(directory);
  } finally {
    await Hive.close();
    HiveBoxes.clearFallbackMemory();
    await directory.delete(recursive: true);
  }
}

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  test('Conversation keys cannot collide through participant separators', () {
    final first = SettingsRepository.conversationKey(ownerId: 'a:b', sitterId: 'c');
    final second = SettingsRepository.conversationKey(ownerId: 'a', sitterId: 'b:c');
    final third = SettingsRepository.conversationKey(ownerId: 'a%3Ab', sitterId: 'c');
    expect(<String>{first, second, third}, hasLength(3));
    expect(
      () => SettingsRepository.conversationKey(ownerId: '', sitterId: 'sitter_1'),
      throwsArgumentError,
    );
  });

  test('Same-name owners and multiple sitters keep independent histories', () async {
    final firstOwner = await _settings.activateOwner(
      email: 'first@example.com',
      name: 'Same display name',
    );
    final secondOwner = await _settings.activateOwner(
      email: 'second@example.com',
      name: 'Same display name',
    );
    expect(firstOwner, isNot(secondOwner));
    await _settings.addChatMessage(
      _message('first_hotel'), ownerId: firstOwner, sitterId: 'sitter_1',
    );
    await _settings.addChatMessage(
      _message('second_hotel'), ownerId: secondOwner, sitterId: 'sitter_1',
    );
    await _settings.addChatMessage(
      _message('first_walker'), ownerId: firstOwner, sitterId: 'sitter_2',
    );
    expect(
      _settings.getChatMessages(ownerId: firstOwner, sitterId: 'sitter_1').single.id,
      'first_hotel',
    );
    expect(
      _settings.getChatMessages(ownerId: secondOwner, sitterId: 'sitter_1').single.id,
      'second_hotel',
    );
    expect(
      _settings.getChatMessages(ownerId: firstOwner, sitterId: 'sitter_2').single.id,
      'first_walker',
    );
    expect(
      _settings.getChatMessages(ownerId: secondOwner, sitterId: 'sitter_2'),
      isEmpty,
    );
  });

  test('Renaming and changing email preserve identity and restore account profile', () async {
    final firstOwner = await _settings.activateOwner(
      email: 'first@example.com', name: 'First Owner',
    );
    await _settings.setUserName('Renamed Owner');
    await _settings.setUserEmail('renamed@example.com');
    expect(_settings.getOwnerId(), firstOwner);
    final secondOwner = await _settings.activateOwner(
      email: 'second@example.com', name: 'Second Owner',
    );
    final restored = await _settings.activateOwner(email: ' RENAMED@EXAMPLE.COM ');
    expect(restored, firstOwner);
    expect(_settings.getOwnerName(), 'Renamed Owner');
    expect(_settings.getUserEmail().toLowerCase(), 'renamed@example.com');
    await _settings.activateOwner(email: 'second@example.com');
    expect(_settings.getOwnerId(), secondOwner);
    expect(_settings.getOwnerName(), 'Second Owner');
    await expectLater(
      _settings.setUserEmail('renamed@example.com'), throwsArgumentError,
    );
    expect(_settings.getOwnerId(), secondOwner);
    expect(_settings.getUserEmail(), 'second@example.com');
  });

  test('Owner identities, booking participants and histories survive Hive reopen', () async {
    await _withHive((directory) async {
      await HiveBoxes.openAndSeedBoxes();
      final firstOwner = await _settings.activateOwner(
        email: 'first@example.com', name: 'First Owner',
      );
      await _settings.addChatMessage(
        _message('first_saved'), ownerId: firstOwner, sitterId: 'sitter_1',
      );
      await const BookingRepository().addBooking(
        HiveSeedData.createInitialBookings().first.copyWith(
          id: 'identity_booking', ownerId: firstOwner,
        ),
      );
      final secondOwner = await _settings.activateOwner(
        email: 'second@example.com', name: 'Second Owner',
      );
      await _settings.addChatMessage(
        _message('second_saved'), ownerId: secondOwner, sitterId: 'sitter_1',
      );
      await Hive.close();
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      expect(_settings.getOwnerId(), secondOwner);
      expect(await _settings.activateOwner(email: 'first@example.com'), firstOwner);
      expect(_settings.getOwnerName(), 'First Owner');
      expect(
        _settings.getChatMessages(ownerId: firstOwner, sitterId: 'sitter_1').single.id,
        'first_saved',
      );
      expect(
        _settings.getChatMessages(ownerId: secondOwner, sitterId: 'sitter_1').single.id,
        'second_saved',
      );
      expect(
        const BookingRepository().getAllBookings().firstWhere(
          (booking) => booking.id == 'identity_booking',
        ).ownerId,
        firstOwner,
      );
    });
  });

  test('Legacy booking owner backfill is separated and stable across reopen', () async {
    await _withHive((directory) async {
      final box = await Hive.openBox<dynamic>(HiveBoxes.bookingsBoxName);
      final seed = HiveSeedData.createInitialBookings().first;
      final entries = <String, Map<String, dynamic>>{
        'legacy_known': seed.copyWith(id: 'legacy_known', ownerName: 'Aygen Y.').toMap()..remove('ownerId'),
        'legacy_second': seed.copyWith(id: 'legacy_second', ownerName: 'Different Owner').toMap()..remove('ownerId'),
        'legacy_unknown': seed.copyWith(id: 'legacy_unknown').toMap()..remove('ownerId')..remove('ownerName'),
      };
      await box.putAll(entries);
      await HiveBoxes.openAndSeedBoxes();
      final before = <String, String>{
        for (final booking in const BookingRepository().getAllBookings())
          booking.id: booking.ownerId,
      };
      expect(before['legacy_known'], ConversationIdentity.legacyOwnerId);
      expect(before.values.toSet(), hasLength(3));
      for (final key in entries.keys) {
        expect((box.get(key) as Map)['ownerId'], before[key]);
      }
      await Hive.close();
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      expect(
        <String, String>{
          for (final booking in const BookingRepository().getAllBookings())
            booking.id: booking.ownerId,
        },
        before,
      );
    });
  });

  test('Legacy scoped chats stay with legacy owner and mixed global rows are archived', () async {
    await _withHive((directory) async {
      final box = await Hive.openBox<dynamic>(HiveBoxes.settingsBoxName);
      await box.putAll(<String, dynamic>{
        'owner_id': 'current_new_owner',
        'user_name': 'New Owner',
        'user_email': 'new@example.com',
        'chat_messages_sitter_1': <Map<String, dynamic>>[
          _message('legacy_hotel').copyWith(senderName: 'Aygen').toMap(),
        ],
        'chat_messages': <Map<String, dynamic>>[
          HiveSeedData.initialChatMessages.first.toMap(),
          _message('unknown_global_recipient').toMap(),
        ],
      });
      await HiveBoxes.openAndSeedBoxes();
      expect(
        _settings.getChatMessages(
          ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1',
        ).single.id,
        'legacy_hotel',
      );
      expect(
        _settings.getChatMessages(
          ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2',
        ).single.id,
        HiveSeedData.initialChatMessages.first.id,
      );
      for (final sitterId in <String>['sitter_1', 'sitter_2']) {
        expect(
          _settings.getChatMessages(ownerId: 'current_new_owner', sitterId: sitterId),
          isEmpty,
        );
      }
      expect(box.get('legacy_chat_archive_chat_messages'), hasLength(2));
      expect(box.containsKey('chat_messages'), isFalse);
      expect(box.containsKey('chat_messages_sitter_1'), isFalse);
      await Hive.close();
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      expect(
        _settings.getChatMessages(
          ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1',
        ),
        hasLength(1),
      );
      expect(
        _settings.getChatMessages(
          ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2',
        ),
        hasLength(1),
      );
    });
  });

  test('Saved provider name repairs only the active listing and is idempotent', () async {
    await _withHive((directory) async {
      final settings = await Hive.openBox<dynamic>(HiveBoxes.settingsBoxName);
      await settings.putAll(<String, String>{
        'active_sitter_id': 'sitter_2', 'sitter_user_name': 'Recovered Provider',
      });
      await HiveBoxes.openAndSeedBoxes();
      final sitters = Hive.box<dynamic>(HiveBoxes.sittersBoxName);
      expect((sitters.get('sitter_2') as Map)['name'], 'Recovered Provider');
      expect((sitters.get('sitter_1') as Map)['name'], 'Ayşe Yılmaz');
      final before = Map<dynamic, dynamic>.from(sitters.toMap());
      await Hive.close();
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      expect(Hive.box<dynamic>(HiveBoxes.sittersBoxName).toMap(), before);
    });
  });

  test('Mixed or unknown legacy scoped owners are archived without exposure', () async {
    await _withHive((directory) async {
      final box = await Hive.openBox<dynamic>(HiveBoxes.settingsBoxName);
      await box.putAll(<String, dynamic>{
        'user_name': 'Deniz Kaya',
        'user_email': 'deniz@example.com',
        'chat_messages_sitter_1': <Map<String, dynamic>>[
          _message('aygen_private').copyWith(senderName: 'Aygen').toMap(),
          _message('deniz_private').copyWith(senderName: 'Deniz').toMap(),
        ],
        'chat_messages_sitter_2': <Map<String, dynamic>>[
          _message('unknown_private').copyWith(senderName: 'Unrecognized Owner').toMap(),
        ],
      });
      await HiveBoxes.openAndSeedBoxes();
      for (final sitterId in <String>['sitter_1', 'sitter_2']) {
        expect(
          _settings.getChatMessages(
            ownerId: _settings.getOwnerId(), sitterId: sitterId,
          ),
          isEmpty,
        );
      }
      expect(box.get('legacy_chat_archive_chat_messages_sitter_1'), hasLength(2));
      expect(box.get('legacy_chat_archive_chat_messages_sitter_2'), hasLength(1));
    });
  });

  test('The saved pre-upgrade owner keeps their bookings and known scoped chat', () async {
    await _withHive((directory) async {
      final settings = await Hive.openBox<dynamic>(HiveBoxes.settingsBoxName);
      await settings.putAll(<String, dynamic>{
        'user_name': 'Deniz Kaya',
        'user_email': 'deniz@example.com',
        'chat_messages_sitter_1': <Map<String, dynamic>>[
          _message('saved_owner_chat').copyWith(senderName: 'Deniz').toMap(),
        ],
      });
      final bookings = await Hive.openBox<dynamic>(HiveBoxes.bookingsBoxName);
      final booking = HiveSeedData.createInitialBookings().first;
      await bookings.putAll(<String, dynamic>{
        'saved_owner_booking': booking.copyWith(
          id: 'saved_owner_booking', ownerName: 'Deniz',
        ).toMap()..remove('ownerId'),
        'different_owner_booking': booking.copyWith(
          id: 'different_owner_booking', ownerName: 'Another Person',
        ).toMap()..remove('ownerId'),
      });
      await HiveBoxes.openAndSeedBoxes();
      final ownerId = _settings.getOwnerId();
      expect(
        (bookings.get('saved_owner_booking') as Map)['ownerId'], ownerId,
      );
      expect(
        (bookings.get('different_owner_booking') as Map)['ownerId'], isNot(ownerId),
      );
      expect(
        _settings.getChatMessages(ownerId: ownerId, sitterId: 'sitter_1').single.id,
        'saved_owner_chat',
      );
      expect(await _settings.activateOwner(email: 'deniz@example.com'), ownerId);
      await Hive.close();
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      expect(_settings.getOwnerId(), ownerId);
      expect(
        (Hive.box<dynamic>(HiveBoxes.bookingsBoxName).get('saved_owner_booking') as Map)['ownerId'],
        ownerId,
      );
    });
  });
}
