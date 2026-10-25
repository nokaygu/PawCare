import 'package:paw_care/data/repositories/conversation_repository.dart';

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

Future<void> _withHive(
  Future<void> Function(Directory directory) action,
) async {
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
    final first = ConversationRepository.conversationKey(
      ownerId: 'a:b',
      sitterId: 'c',
    );
    final second = ConversationRepository.conversationKey(
      ownerId: 'a',
      sitterId: 'b:c',
    );
    final third = ConversationRepository.conversationKey(
      ownerId: 'a%3Ab',
      sitterId: 'c',
    );
    expect(<String>{first, second, third}, hasLength(3));
    expect(
      () => ConversationRepository.conversationKey(
        ownerId: '',
        sitterId: 'sitter_1',
      ),
      throwsArgumentError,
    );
  });

  test(
    'Same-name owners and multiple sitters keep independent histories',
    () async {
      final firstOwner = await _settings.activateOwner(
        email: 'first@example.com',
        name: 'Same display name',
      );
      final secondOwner = await _settings.activateOwner(
        email: 'second@example.com',
        name: 'Same display name',
      );
      expect(firstOwner, isNot(secondOwner));
      await const ConversationRepository().addMessage(
        _message('first_hotel'),
        ownerId: firstOwner,
        sitterId: 'sitter_1',
      );
      await const ConversationRepository().addMessage(
        _message('second_hotel'),
        ownerId: secondOwner,
        sitterId: 'sitter_1',
      );
      await const ConversationRepository().addMessage(
        _message('first_walker'),
        ownerId: firstOwner,
        sitterId: 'sitter_2',
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: firstOwner,
          sitterId: 'sitter_1',
        )).single.id,
        'first_hotel',
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: secondOwner,
          sitterId: 'sitter_1',
        )).single.id,
        'second_hotel',
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: firstOwner,
          sitterId: 'sitter_2',
        )).single.id,
        'first_walker',
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: secondOwner,
          sitterId: 'sitter_2',
        )),
        isEmpty,
      );
    },
  );

  test(
    'Renaming and changing email preserve identity and restore account profile',
    () async {
      final firstOwner = await _settings.activateOwner(
        email: 'first@example.com',
        name: 'First Owner',
      );
      await _settings.setUserName('Renamed Owner');
      await _settings.setUserEmail('renamed@example.com');
      expect(_settings.getOwnerId(), firstOwner);
      final secondOwner = await _settings.activateOwner(
        email: 'second@example.com',
        name: 'Second Owner',
      );
      final restored = await _settings.activateOwner(
        email: ' RENAMED@EXAMPLE.COM ',
      );
      expect(restored, firstOwner);
      expect(_settings.getOwnerName(), 'Renamed Owner');
      expect(_settings.getUserEmail().toLowerCase(), 'renamed@example.com');
      await _settings.activateOwner(email: 'second@example.com');
      expect(_settings.getOwnerId(), secondOwner);
      expect(_settings.getOwnerName(), 'Second Owner');
      await expectLater(
        _settings.setUserEmail('renamed@example.com'),
        throwsArgumentError,
      );
      expect(_settings.getOwnerId(), secondOwner);
      expect(_settings.getUserEmail(), 'second@example.com');
    },
  );

  test(
    'Owner identities, booking participants and histories survive Hive reopen',
    () async {
      await _withHive((directory) async {
        await HiveBoxes.openAndSeedBoxes();
        final firstOwner = await _settings.activateOwner(
          email: 'first@example.com',
          name: 'First Owner',
        );
        await const ConversationRepository().addMessage(
          _message('first_saved'),
          ownerId: firstOwner,
          sitterId: 'sitter_1',
        );
        await BookingRepository().addBooking(
          HiveSeedData.createInitialBookings().first.copyWith(
            id: 'identity_booking',
            ownerId: firstOwner,
          ),
        );
        final secondOwner = await _settings.activateOwner(
          email: 'second@example.com',
          name: 'Second Owner',
        );
        await const ConversationRepository().addMessage(
          _message('second_saved'),
          ownerId: secondOwner,
          sitterId: 'sitter_1',
        );
        await Hive.close();
        Hive.init(directory.path);
        await HiveBoxes.openAndSeedBoxes();
        expect(_settings.getOwnerId(), secondOwner);
        expect(
          await _settings.activateOwner(email: 'first@example.com'),
          firstOwner,
        );
        expect(_settings.getOwnerName(), 'First Owner');
        expect(
          (await const ConversationRepository().readAll(
            ownerId: firstOwner,
            sitterId: 'sitter_1',
          )).single.id,
          'first_saved',
        );
        expect(
          (await const ConversationRepository().readAll(
            ownerId: secondOwner,
            sitterId: 'sitter_1',
          )).single.id,
          'second_saved',
        );
        expect(
          BookingRepository()
              .getAllBookings()
              .firstWhere((booking) => booking.id == 'identity_booking')
              .ownerId,
          firstOwner,
        );
      });
    },
  );
}
