import 'package:flutter/foundation.dart';

import 'conversation_identity.dart';

export 'conversation_identity.dart';

enum UserRole { owner, sitter }

enum VaccineStatus { completed, upcoming, overdue }

enum BookingStatus { pending, confirmed, rejected, completed }

enum NotificationType {
  bookingCreated,
  bookingStatusChanged,
  vaccineReminder,
  walkStatus,
}

@immutable
class Vaccination {
  final String id;
  final String title;
  final String dueDate;
  final VaccineStatus status;
  final String vetName;
  final String? completionDate;

  const Vaccination({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    required this.vetName,
    this.completionDate,
  });

  Vaccination copyWith({
    String? id,
    String? title,
    String? dueDate,
    VaccineStatus? status,
    String? vetName,
    String? completionDate,
  }) {
    return Vaccination(
      id: id ?? this.id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      vetName: vetName ?? this.vetName,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'dueDate': dueDate,
      'status': status.name,
      'vetName': vetName,
      'completionDate': completionDate,
    };
  }

  factory Vaccination.fromMap(Map<dynamic, dynamic> map) {
    final statusName = map['status'] as String? ?? VaccineStatus.upcoming.name;
    final parsedStatus = VaccineStatus.values.firstWhere(
      (e) => e.name == statusName,
      orElse: () => VaccineStatus.upcoming,
    );
    return Vaccination(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      dueDate: map['dueDate'] as String? ?? '',
      status: parsedStatus,
      vetName: map['vetName'] as String? ?? '',
      completionDate: map['completionDate'] as String?,
    );
  }
}

@immutable
class Dog {
  final String id;
  final String name;
  final String breed;
  final int ageYears;
  final double weightKg;
  final String gender;
  final String microchip;
  final String photoPath;
  final String allergyNote;
  final String behaviorNote;
  final String clinicName;
  final String clinicPhone;
  final List<Vaccination> vaccinations;

  const Dog({
    required this.id,
    required this.name,
    required this.breed,
    required this.ageYears,
    required this.weightKg,
    required this.gender,
    required this.microchip,
    required this.photoPath,
    required this.allergyNote,
    required this.behaviorNote,
    required this.clinicName,
    required this.clinicPhone,
    required this.vaccinations,
  });

  Dog copyWith({
    String? id,
    String? name,
    String? breed,
    int? ageYears,
    double? weightKg,
    String? gender,
    String? microchip,
    String? photoPath,
    String? allergyNote,
    String? behaviorNote,
    String? clinicName,
    String? clinicPhone,
    List<Vaccination>? vaccinations,
  }) {
    return Dog(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      ageYears: ageYears ?? this.ageYears,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      microchip: microchip ?? this.microchip,
      photoPath: photoPath ?? this.photoPath,
      allergyNote: allergyNote ?? this.allergyNote,
      behaviorNote: behaviorNote ?? this.behaviorNote,
      clinicName: clinicName ?? this.clinicName,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      vaccinations: vaccinations ?? this.vaccinations,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'breed': breed,
      'ageYears': ageYears,
      'weightKg': weightKg,
      'gender': gender,
      'microchip': microchip,
      'photoPath': photoPath,
      'allergyNote': allergyNote,
      'behaviorNote': behaviorNote,
      'clinicName': clinicName,
      'clinicPhone': clinicPhone,
      'vaccinations': vaccinations.map((v) => v.toMap()).toList(),
    };
  }

  factory Dog.fromMap(Map<dynamic, dynamic> map) {
    final rawVaccinations =
        map['vaccinations'] as List<dynamic>? ?? <dynamic>[];
    return Dog(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      breed: map['breed'] as String? ?? '',
      ageYears: (map['ageYears'] as num?)?.toInt() ?? 1,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 10.0,
      gender: map['gender'] as String? ?? '',
      microchip: map['microchip'] as String? ?? '',
      photoPath: map['photoPath'] as String? ?? 'assets/images/barley.jpg',
      allergyNote: map['allergyNote'] as String? ?? '',
      behaviorNote: map['behaviorNote'] as String? ?? '',
      clinicName: map['clinicName'] as String? ?? '',
      clinicPhone: map['clinicPhone'] as String? ?? '',
      vaccinations: rawVaccinations
          .map(
            (item) =>
                Vaccination.fromMap(Map<dynamic, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}

@immutable
class SitterListing {
  final String id;
  final String name;
  final String facilityTitle;
  final String category;
  final double rating;
  final int reviewsCount;
  final double pricePerUnit;
  final String unitLabel;
  final String location;
  final double distanceKm;
  final String imagePath;
  final List<String> galleryPaths;
  final String bio;
  final List<String> amenities;
  final bool isVerified;
  final List<DateTime> unavailableDates;

  const SitterListing({
    required this.id,
    required this.name,
    required this.facilityTitle,
    required this.category,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerUnit,
    required this.unitLabel,
    required this.location,
    required this.distanceKm,
    required this.imagePath,
    required this.galleryPaths,
    required this.bio,
    required this.amenities,
    this.isVerified = true,
    this.unavailableDates = const <DateTime>[],
  });

  SitterListing copyWith({
    String? id,
    String? name,
    String? facilityTitle,
    String? category,
    double? rating,
    int? reviewsCount,
    double? pricePerUnit,
    String? unitLabel,
    String? location,
    double? distanceKm,
    String? imagePath,
    List<String>? galleryPaths,
    String? bio,
    List<String>? amenities,
    bool? isVerified,
    List<DateTime>? unavailableDates,
  }) {
    return SitterListing(
      id: id ?? this.id,
      name: name ?? this.name,
      facilityTitle: facilityTitle ?? this.facilityTitle,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      unitLabel: unitLabel ?? this.unitLabel,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      imagePath: imagePath ?? this.imagePath,
      galleryPaths: galleryPaths ?? this.galleryPaths,
      bio: bio ?? this.bio,
      amenities: amenities ?? this.amenities,
      isVerified: isVerified ?? this.isVerified,
      unavailableDates: unavailableDates ?? this.unavailableDates,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'facilityTitle': facilityTitle,
      'category': category,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'pricePerUnit': pricePerUnit,
      'unitLabel': unitLabel,
      'location': location,
      'distanceKm': distanceKm,
      'imagePath': imagePath,
      'galleryPaths': galleryPaths,
      'bio': bio,
      'amenities': amenities,
      'isVerified': isVerified,
      'unavailableDates': unavailableDates
          .map((d) => d.millisecondsSinceEpoch)
          .toList(),
    };
  }

  factory SitterListing.fromMap(Map<dynamic, dynamic> map) {
    final rawGallery = map['galleryPaths'] as List<dynamic>? ?? <dynamic>[];
    final rawAmenities = map['amenities'] as List<dynamic>? ?? <dynamic>[];
    final rawDates = map['unavailableDates'] as List<dynamic>? ?? <dynamic>[];
    return SitterListing(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      facilityTitle: map['facilityTitle'] as String? ?? '',
      category: map['category'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (map['reviewsCount'] as num?)?.toInt() ?? 0,
      pricePerUnit: (map['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
      unitLabel: map['unitLabel'] as String? ?? 'gece',
      location: map['location'] as String? ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 1.0,
      imagePath: map['imagePath'] as String? ?? 'assets/images/ayse.jpg',
      galleryPaths: rawGallery.map((e) => e.toString()).toList(),
      bio: map['bio'] as String? ?? '',
      amenities: rawAmenities.map((e) => e.toString()).toList(),
      isVerified: map['isVerified'] as bool? ?? true,
      unavailableDates: rawDates
          .map((ms) => DateTime.fromMillisecondsSinceEpoch((ms as num).toInt()))
          .toList(),
    );
  }
}

@immutable
class BookingRequest {
  final String id;
  final String sitterId;
  final String sitterName;
  final String sitterPhoto;
  final String petName;
  final String petBreed;
  final String petPhotoPath;
  final String ownerName;
  final String ownerId;
  final String serviceTitle;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String careNotes;
  final BookingStatus status;

  const BookingRequest({
    required this.id,
    required this.sitterId,
    required this.sitterName,
    required this.sitterPhoto,
    required this.petName,
    required this.petBreed,
    this.petPhotoPath = 'assets/images/barley.jpg',
    this.ownerName = 'Aygen',
    this.ownerId = ConversationIdentity.legacyOwnerId,
    required this.serviceTitle,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.careNotes,
    this.status = BookingStatus.pending,
  });

  BookingRequest copyWith({
    String? id,
    String? sitterId,
    String? sitterName,
    String? sitterPhoto,
    String? petName,
    String? petBreed,
    String? petPhotoPath,
    String? ownerName,
    String? ownerId,
    String? serviceTitle,
    DateTime? startDate,
    DateTime? endDate,
    double? totalPrice,
    String? careNotes,
    BookingStatus? status,
  }) {
    return BookingRequest(
      id: id ?? this.id,
      sitterId: sitterId ?? this.sitterId,
      sitterName: sitterName ?? this.sitterName,
      sitterPhoto: sitterPhoto ?? this.sitterPhoto,
      petName: petName ?? this.petName,
      petBreed: petBreed ?? this.petBreed,
      petPhotoPath: petPhotoPath ?? this.petPhotoPath,
      ownerName: ownerName ?? this.ownerName,
      ownerId: ownerId ?? this.ownerId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalPrice: totalPrice ?? this.totalPrice,
      careNotes: careNotes ?? this.careNotes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sitterId': sitterId,
      'sitterName': sitterName,
      'sitterPhoto': sitterPhoto,
      'petName': petName,
      'petBreed': petBreed,
      'petPhotoPath': petPhotoPath,
      'ownerName': ownerName,
      'ownerId': ownerId,
      'serviceTitle': serviceTitle,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'totalPrice': totalPrice,
      'careNotes': careNotes,
      'status': status.name,
    };
  }

  factory BookingRequest.fromMap(Map<dynamic, dynamic> map) {
    final statusName = map['status'] as String? ?? BookingStatus.pending.name;
    final parsedStatus = BookingStatus.values.firstWhere(
      (e) => e.name == statusName,
      orElse: () => BookingStatus.pending,
    );
    return BookingRequest(
      id: map['id'] as String? ?? '',
      sitterId: map['sitterId'] as String? ?? '',
      sitterName: map['sitterName'] as String? ?? '',
      sitterPhoto: map['sitterPhoto'] as String? ?? 'assets/images/ayse.jpg',
      petName: map['petName'] as String? ?? '',
      petBreed: map['petBreed'] as String? ?? '',
      petPhotoPath:
          map['petPhotoPath'] as String? ?? 'assets/images/barley.jpg',
      ownerName: map['ownerName'] as String? ?? 'Aygen',
      ownerId: (map['ownerId'] as String?)?.trim().isNotEmpty == true
          ? map['ownerId'] as String
          : ConversationIdentity.ownerIdForLegacyBooking(
              ownerName: map['ownerName'] as String?,
              bookingId: map['id'] as String? ?? '',
            ),
      serviceTitle: map['serviceTitle'] as String? ?? '',
      startDate: DateTime.fromMillisecondsSinceEpoch(
        (map['startDate'] as num?)?.toInt() ?? 0,
      ),
      endDate: DateTime.fromMillisecondsSinceEpoch(
        (map['endDate'] as num?)?.toInt() ?? 0,
      ),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      careNotes: map['careNotes'] as String? ?? '',
      status: parsedStatus,
    );
  }
}

@immutable
class ChatMessage {
  final String id;
  final String senderName;
  final String text;
  final String time;
  final bool isMe;
  final UserRole? senderRole;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isMe,
    this.senderRole,
  });

  ChatMessage copyWith({
    String? id,
    String? senderName,
    String? text,
    String? time,
    bool? isMe,
    UserRole? senderRole,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      time: time ?? this.time,
      isMe: isMe ?? this.isMe,
      senderRole: senderRole ?? this.senderRole,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'senderName': senderName,
      'text': text,
      'time': time,
      'isMe': isMe,
      'senderRole': senderRole?.name,
    };
  }

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String? ?? '',
      senderName: map['senderName'] as String? ?? '',
      text: map['text'] as String? ?? '',
      time: map['time'] as String? ?? '',
      isMe: map['isMe'] as bool? ?? false,
      senderRole: switch (map['senderRole']) {
        'owner' => UserRole.owner,
        'sitter' => UserRole.sitter,
        _ => null,
      },
    );
  }
}

@immutable
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeLabel;
  final NotificationType type;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timeLabel,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'message': message,
      'timeLabel': timeLabel,
      'type': type.name,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromMap(Map<dynamic, dynamic> map) {
    final typeName =
        map['type'] as String? ?? NotificationType.bookingCreated.name;
    final parsedType = NotificationType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => NotificationType.bookingCreated,
    );
    return NotificationItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      timeLabel: map['timeLabel'] as String? ?? '',
      type: parsedType,
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}
