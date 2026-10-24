import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paw_care/data/local/hive_boxes.dart';
import 'package:paw_care/data/local/hive_seed_data.dart';
import 'package:paw_care/data/models/models.dart';
import 'package:paw_care/data/repositories/booking_repository.dart';
import 'package:paw_care/data/repositories/notification_repository.dart';
import 'package:paw_care/data/repositories/settings_repository.dart';

void main() {
  setUp(HiveBoxes.clearFallbackMemory);
  tearDown(HiveBoxes.clearFallbackMemory);

  test('Nonconstant demo lists are created independently for each seed', () {
    final sitters = HiveSeedData.createInitialSitters();
    final bookings = HiveSeedData.createInitialBookings();
    sitters.first.unavailableDates.clear();
    sitters.clear();
    bookings.clear();

    expect(HiveSeedData.createInitialSitters(), hasLength(3));
    expect(
      HiveSeedData.createInitialSitters().first.unavailableDates,
      hasLength(2),
    );
    expect(HiveSeedData.createInitialBookings(), hasLength(2));
  });

  test(
    'Fallback reset releases previous settings and restores defaults',
    () async {
      const settings = SettingsRepository();
      expect(settings.getActiveDogId(), HiveSeedData.initialDog.id);
      await settings.setActiveDogId('temporary_dog');
      await settings.setUserName('Changed owner');

      HiveBoxes.clearFallbackMemory();

      expect(settings.getActiveDogId(), HiveSeedData.initialDog.id);
      expect(settings.getOwnerName(), isNot('Changed owner'));
    },
  );

  test('Chat histories use sitter identities and remain separate', () async {
    const settings = SettingsRepository();
    expect(settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1'), isEmpty);
    expect(settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2'), hasLength(3));
    const message = ChatMessage(
      id: 'test_message',
      senderName: 'Owner',
      text: 'Only for the hotel',
      time: '12:30',
      isMe: true,
      senderRole: UserRole.owner,
    );
    await settings.addChatMessage(message, ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1');
    await settings.setSitterName('Renamed provider');

    expect(
      settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1').single.text,
      message.text,
    );
    expect(settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2'), hasLength(3));
    expect(settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_3'), isEmpty);
    expect(
      () => settings.getChatMessages(contactKey: ' '),
      throwsArgumentError,
    );
  });

  test(
    'A cleared conversation stays empty without reusing demo messages',
    () async {
      await HiveBoxes.putValue(
        HiveBoxes.settingsBoxName,
        'chat_messages_${SettingsRepository.conversationKey(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2')}',
        <dynamic>[],
      );
      expect(
        const SettingsRepository().getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2'),
        isEmpty,
      );
    },
  );

  test(
    'Chat sender roles survive storage and legacy messages stay readable',
    () {
      const message = ChatMessage(
        id: 'message',
        senderName: 'Provider',
        text: 'Hello',
        time: '10:00',
        isMe: true,
        senderRole: UserRole.sitter,
      );
      expect(ChatMessage.fromMap(message.toMap()).senderRole, UserRole.sitter);
      final legacy = message.toMap()..remove('senderRole');
      expect(ChatMessage.fromMap(legacy).senderRole, isNull);
      expect(ChatMessage.fromMap(legacy).isMe, isTrue);
    },
  );

  test('Booking and notification IDs sort by numeric sequence', () async {
    const bookings = BookingRepository();
    const notifications = NotificationRepository();
    final booking = HiveSeedData.createInitialBookings().first;
    final notification = HiveSeedData.initialNotifications.first;
    for (final sequence in <int>[2, 10]) {
      await bookings.addBooking(booking.copyWith(id: 'record_$sequence'));
      await notifications.addNotification(
        notification.copyWith(id: 'notice_$sequence'),
      );
    }
    final bookingIds = bookings
        .getAllBookings()
        .map((item) => item.id)
        .toList();
    final notificationIds = notifications
        .getAllNotifications()
        .map((item) => item.id)
        .toList();
    expect(
      bookingIds.indexOf('record_10'),
      lessThan(bookingIds.indexOf('record_2')),
    );
    expect(
      notificationIds.indexOf('notice_10'),
      lessThan(notificationIds.indexOf('notice_2')),
    );
  });

  test(
    'Hive migrates legacy chat once and respects empty persisted lists',
    () async {
      final directory = await Directory.systemTemp.createTemp('pawcare_hive_');
      try {
        Hive.init(directory.path);
        final settingsBox = await Hive.openBox<dynamic>(
          HiveBoxes.settingsBoxName,
        );
        final legacyMessages = <Map<String, dynamic>>[
          HiveSeedData.initialChatMessages.first.toMap(),
        ];
        await settingsBox.put('chat_messages', legacyMessages);

        await HiveBoxes.openAndSeedBoxes();

        const settings = SettingsRepository();
        expect(settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2'), hasLength(1));
        expect(settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1'), isEmpty);
        expect(settingsBox.containsKey('chat_messages'), isFalse);

        await settings.setActiveDogId('persisted_dog');
        await settings.addChatMessage(
          const ChatMessage(
            id: 'persisted_message',
            senderName: 'Provider',
            text: 'Stored on disk',
            time: '09:00',
            isMe: true,
            senderRole: UserRole.sitter,
          ),
          ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1',
        );
        await Hive.close();
        Hive.init(directory.path);
        await HiveBoxes.openAndSeedBoxes();
        expect(settings.getActiveDogId(), 'persisted_dog');
        expect(
          settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1').single.text,
          'Stored on disk',
        );
        expect(
          settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_1').single.senderRole,
          UserRole.sitter,
        );
        expect(settings.getChatMessages(ownerId: ConversationIdentity.legacyOwnerId, sitterId: 'sitter_2'), hasLength(1));

        await Hive.box<dynamic>(HiveBoxes.bookingsBoxName).clear();
        await Hive.box<dynamic>(HiveBoxes.notificationsBoxName).clear();
        expect(const BookingRepository().getAllBookings(), isEmpty);
        expect(const NotificationRepository().getAllNotifications(), isEmpty);
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
