import 'package:paw_care/data/repositories/conversation_repository.dart';

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
    expect(
      () => sitters.first.unavailableDates.clear(),
      throwsUnsupportedError,
    );
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
    expect(
      (await const ConversationRepository().readAll(
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_1',
      )),
      isEmpty,
    );
    expect(
      (await const ConversationRepository().readAll(
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_2',
      )),
      hasLength(3),
    );
    const message = ChatMessage(
      id: 'test_message',
      senderName: 'Owner',
      text: 'Only for the hotel',
      time: '12:30',
      isMe: true,
      senderRole: UserRole.owner,
    );
    await const ConversationRepository().addMessage(
      message,
      ownerId: HiveSeedData.demoOwnerId,
      sitterId: 'sitter_1',
    );
    await settings.setSitterName('Renamed provider');

    expect(
      (await const ConversationRepository().readAll(
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_1',
      )).single.text,
      message.text,
    );
    expect(
      (await const ConversationRepository().readAll(
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_2',
      )),
      hasLength(3),
    );
    expect(
      (await const ConversationRepository().readAll(
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_3',
      )),
      isEmpty,
    );
    expect(
      () => const ConversationRepository().readAll(
        ownerId: ' ',
        sitterId: 'sitter_1',
      ),
      throwsArgumentError,
    );
  });

  test(
    'A cleared conversation stays empty without reusing demo messages',
    () async {
      await const ConversationRepository().archiveConversation(
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_2',
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_2',
        )),
        isEmpty,
      );
    },
  );

  test('Chat sender roles round trip and missing roles are rejected', () {
    const message = ChatMessage(
      id: 'message',
      senderName: 'Provider',
      text: 'Hello',
      time: '10:00',
      isMe: true,
      senderRole: UserRole.sitter,
    );
    expect(ChatMessage.fromMap(message.toMap()).senderRole, UserRole.sitter);
    final incomplete = message.toMap()..remove('senderRole');
    expect(() => ChatMessage.fromMap(incomplete), throwsA(isA<TypeError>()));
  });

  test('Required account and booking fields are never inferred', () {
    final dog = HiveSeedData.initialDog.toMap()..remove('ownerId');
    expect(() => Dog.fromMap(dog), throwsA(isA<TypeError>()));
    for (final field in [
      'ownerId',
      'petId',
      'serviceType',
      'createdAt',
      'units',
      'unitPriceCents',
      'serviceFeeCents',
    ]) {
      final booking = HiveSeedData.createInitialBookings().first.toMap()
        ..remove(field);
      expect(
        () => BookingRequest.fromMap(booking),
        throwsA(anyOf(isA<TypeError>(), isA<ArgumentError>())),
      );
    }
    final listing = HiveSeedData.createInitialSitters().first.toMap()
      ..remove('serviceType');
    expect(() => SitterListing.fromMap(listing), throwsA(isA<TypeError>()));
    final notification = HiveSeedData.initialNotifications.first.toMap()
      ..remove('createdAt');
    expect(
      () => NotificationItem.fromMap(notification),
      throwsA(isA<TypeError>()),
    );
  });

  test('Booking and notification IDs sort by numeric sequence', () async {
    final bookings = BookingRepository();
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

  test('Hive seeds current conversations directly and preserves intentional empty data', () async {
    final directory = await Directory.systemTemp.createTemp('pawcare_hive_');
    try {
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      final settingsBox = Hive.box<dynamic>(HiveBoxes.settingsBoxName);
      expect(settingsBox.get('initial_data_created'), isTrue);
      expect(
        settingsBox.keys.whereType<String>().any(
          (key) => key.startsWith('chat_messages'),
        ),
        isFalse,
      );
      expect(Hive.lazyBox<dynamic>(HiveBoxes.messagesBoxName).length, 3);
      const settings = SettingsRepository();
      expect(
        (await const ConversationRepository().readAll(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_2',
        )),
        hasLength(3),
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_1',
        )),
        isEmpty,
      );

      await settings.setActiveDogId('persisted_dog');
      await const ConversationRepository().addMessage(
        const ChatMessage(
          id: 'persisted_message',
          senderName: 'Provider',
          text: 'Stored on disk',
          time: '09:00',
          isMe: true,
          senderRole: UserRole.sitter,
        ),
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_1',
      );
      await Hive.close();
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      expect(settings.getActiveDogId(), 'persisted_dog');
      expect(
        (await const ConversationRepository().readAll(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_1',
        )).single.text,
        'Stored on disk',
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_1',
        )).single.senderRole,
        UserRole.sitter,
      );
      expect(
        (await const ConversationRepository().readAll(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_2',
        )),
        hasLength(3),
      );

      await const ConversationRepository().archiveConversation(
        ownerId: HiveSeedData.demoOwnerId,
        sitterId: 'sitter_2',
      );
      for (final box in [
        HiveBoxes.bookingsBoxName,
        HiveBoxes.notificationsBoxName,
        HiveBoxes.dogsBoxName,
      ]) {
        await Hive.box<dynamic>(box).clear();
      }
      await Hive.close();
      Hive.init(directory.path);
      await HiveBoxes.openAndSeedBoxes();
      expect(BookingRepository().getAllBookings(), isEmpty);
      expect(const NotificationRepository().getAllNotifications(), isEmpty);
      expect(Hive.box<dynamic>(HiveBoxes.dogsBoxName).isEmpty, isTrue);
      expect(
        await const ConversationRepository().readAll(
          ownerId: HiveSeedData.demoOwnerId,
          sitterId: 'sitter_2',
        ),
        isEmpty,
      );
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}
