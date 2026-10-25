import 'package:flutter/foundation.dart';

import 'service_type.dart';
import 'calendar_date.dart';
import '../../core/constants/app_strings.dart';

export 'conversation_identity.dart';
export 'service_type.dart';
export 'money.dart';

enum UserRole { owner, sitter }

enum VaccineStatus { completed, upcoming, overdue }

enum BookingStatus { pending, confirmed, rejected, completed, cancelled }

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
  final DateTime? dueAt;
  final VaccineStatus status;
  final String vetName;
  final DateTime? completedAt;
  Vaccination({
    required this.id,
    required this.title,
    required DateTime? dueAt,
    required this.status,
    required this.vetName,
    this.completedAt,
  }) : dueAt = dueAt == null ? null : CalendarDate.day(dueAt);

  String get dueDate => dueAt == null
      ? AppStrings.dateUnknown
      : AppStrings.formatShortDate(dueAt!);
  String? get completionDate =>
      completedAt == null ? null : AppStrings.formatShortDate(completedAt!);
  VaccineStatus statusAt(DateTime now) {
    if (status == VaccineStatus.completed) return status;
    if (dueAt == null) return status;
    return dueAt!.isBefore(CalendarDate.day(now))
        ? VaccineStatus.overdue
        : VaccineStatus.upcoming;
  }

  Vaccination copyWith({
    String? id,
    String? title,
    DateTime? dueAt,
    VaccineStatus? status,
    String? vetName,
    DateTime? completedAt,
    bool clearCompletion = false,
  }) => Vaccination(
    id: id ?? this.id,
    title: title ?? this.title,
    dueAt: dueAt ?? this.dueAt,
    status: status ?? this.status,
    vetName: vetName ?? this.vetName,
    completedAt: clearCompletion ? null : completedAt ?? this.completedAt,
  );

  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'dueOn': dueAt == null ? null : CalendarDate.iso(dueAt!),
    'status': status.name,
    'vetName': vetName,
    'completedAt': completedAt?.millisecondsSinceEpoch,
  };

  factory Vaccination.fromMap(Map<dynamic, dynamic> map) {
    if (!map.containsKey('dueOn')) {
      throw const FormatException('Missing vaccination date');
    }
    final date = map['dueOn'] as String?;
    final due = CalendarDate.tryParse(date);
    if (date != null && due == null) {
      throw const FormatException('Invalid vaccination date');
    }
    return Vaccination(
      id: map['id'] as String,
      title: map['title'] as String,
      dueAt: due,
      status: VaccineStatus.values.byName(map['status'] as String),
      vetName: map['vetName'] as String,
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
    );
  }
}

@immutable
class Dog {
  final String id;
  final String ownerId;
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
  final String nutritionPlan;
  final String veterinarianName;
  final List<Vaccination> vaccinations;

  Dog({
    required this.id,
    required this.ownerId,
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
    this.nutritionPlan = '',
    this.veterinarianName = '',
    required List<Vaccination> vaccinations,
  }) : vaccinations = List.unmodifiable(vaccinations);

  Dog copyWith({
    String? id,
    String? ownerId,
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
    String? nutritionPlan,
    String? veterinarianName,
    List<Vaccination>? vaccinations,
  }) {
    return Dog(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
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
      nutritionPlan: nutritionPlan ?? this.nutritionPlan,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      vaccinations: vaccinations ?? this.vaccinations,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'ownerId': ownerId,
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
      'nutritionPlan': nutritionPlan,
      'veterinarianName': veterinarianName,
      'vaccinations': vaccinations.map((v) => v.toMap()).toList(),
    };
  }

  factory Dog.fromMap(Map<dynamic, dynamic> map) {
    final rawVaccinations = map['vaccinations'] as List;
    return Dog(
      id: map['id'] as String,
      ownerId: map['ownerId'] as String,
      name: map['name'] as String,
      breed: map['breed'] as String,
      ageYears: (map['ageYears'] as num).toInt(),
      weightKg: (map['weightKg'] as num).toDouble(),
      gender: map['gender'] as String,
      microchip: map['microchip'] as String,
      photoPath: map['photoPath'] as String,
      allergyNote: map['allergyNote'] as String,
      behaviorNote: map['behaviorNote'] as String,
      clinicName: map['clinicName'] as String,
      clinicPhone: map['clinicPhone'] as String,
      nutritionPlan: map['nutritionPlan'] as String,
      veterinarianName: map['veterinarianName'] as String,
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
  final bool isPublished;
  final ServiceType serviceType;
  final int capacity;
  final List<DateTime> unavailableDates;

  SitterListing({
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
    required List<String> galleryPaths,
    required this.bio,
    required List<String> amenities,
    this.isVerified = false,
    this.isPublished = true,
    required this.serviceType,
    this.capacity = 1,
    List<DateTime> unavailableDates = const <DateTime>[],
  }) : galleryPaths = List.unmodifiable(galleryPaths),
       amenities = List.unmodifiable(amenities),
       unavailableDates = List.unmodifiable(unavailableDates);

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
    bool? isPublished,
    ServiceType? serviceType,
    int? capacity,
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
      isPublished: isPublished ?? this.isPublished,
      serviceType: serviceType ?? this.serviceType,
      capacity: capacity ?? this.capacity,
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
      'isPublished': isPublished,
      'serviceType': serviceType.name,
      'capacity': capacity,
      'unavailableDates': unavailableDates
          .map((d) => d.millisecondsSinceEpoch)
          .toList(),
    };
  }

  factory SitterListing.fromMap(Map<dynamic, dynamic> map) {
    final rawGallery = map['galleryPaths'] as List;
    final rawAmenities = map['amenities'] as List;
    final rawDates = map['unavailableDates'] as List;
    return SitterListing(
      id: map['id'] as String,
      name: map['name'] as String,
      facilityTitle: map['facilityTitle'] as String,
      category: map['category'] as String,
      rating: (map['rating'] as num).toDouble(),
      reviewsCount: (map['reviewsCount'] as num).toInt(),
      pricePerUnit: (map['pricePerUnit'] as num).toDouble(),
      unitLabel: map['unitLabel'] as String,
      location: map['location'] as String,
      distanceKm: (map['distanceKm'] as num).toDouble(),
      imagePath: map['imagePath'] as String,
      galleryPaths: rawGallery.cast<String>(),
      bio: map['bio'] as String,
      amenities: rawAmenities.cast<String>(),
      isVerified: map['isVerified'] as bool,
      isPublished: map['isPublished'] as bool,
      serviceType: ServiceType.values.byName(map['serviceType'] as String),
      capacity: map['capacity'] as int,
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
  final String petId;
  final ServiceType serviceType;
  final int units;
  final int unitPriceCents;
  final int serviceFeeCents;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool isActiveAt(DateTime now) =>
      status == BookingStatus.confirmed &&
      !now.isBefore(startDate) &&
      now.isBefore(endDate);

  bool canCancelAt(DateTime now) =>
      status == BookingStatus.pending ||
      (status == BookingStatus.confirmed && now.isBefore(startDate));

  const BookingRequest({
    required this.id,
    required this.sitterId,
    required this.sitterName,
    required this.sitterPhoto,
    required this.petName,
    required this.petBreed,
    this.petPhotoPath = '',
    required this.ownerName,
    required this.ownerId,
    required this.serviceTitle,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.careNotes,
    this.status = BookingStatus.pending,
    required this.petId,
    required this.serviceType,
    required this.units,
    required this.unitPriceCents,
    required this.serviceFeeCents,
    required this.createdAt,
    this.completedAt,
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
    String? petId,
    ServiceType? serviceType,
    int? units,
    int? unitPriceCents,
    int? serviceFeeCents,
    DateTime? createdAt,
    DateTime? completedAt,
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
      petId: petId ?? this.petId,
      serviceType: serviceType ?? this.serviceType,
      units: units ?? this.units,
      unitPriceCents: unitPriceCents ?? this.unitPriceCents,
      serviceFeeCents: serviceFeeCents ?? this.serviceFeeCents,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
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
      'petId': petId,
      'serviceType': serviceType.name,
      'units': units,
      'unitPriceCents': unitPriceCents,
      'serviceFeeCents': serviceFeeCents,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'status': status.name,
    };
  }

  factory BookingRequest.fromMap(Map<dynamic, dynamic> map) => BookingRequest(
    id: map['id'] as String,
    sitterId: map['sitterId'] as String,
    sitterName: map['sitterName'] as String,
    sitterPhoto: map['sitterPhoto'] as String,
    petName: map['petName'] as String,
    petBreed: map['petBreed'] as String,
    petPhotoPath: map['petPhotoPath'] as String,
    ownerName: map['ownerName'] as String,
    ownerId: map['ownerId'] as String,
    serviceTitle: map['serviceTitle'] as String,
    startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] as int),
    endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] as int),
    totalPrice: (map['totalPrice'] as num).toDouble(),
    careNotes: map['careNotes'] as String,
    petId: map['petId'] as String,
    serviceType: ServiceType.values.byName(map['serviceType'] as String),
    units: map['units'] as int,
    unitPriceCents: map['unitPriceCents'] as int,
    serviceFeeCents: map['serviceFeeCents'] as int,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    completedAt: map['completedAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int),
    status: BookingStatus.values.byName(map['status'] as String),
  );
}

@immutable
class ChatMessage {
  final String id;
  final String senderName;
  final String text;
  final String time;
  final bool isMe;
  final UserRole senderRole;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isMe,
    required this.senderRole,
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
      'senderRole': senderRole.name,
    };
  }

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      senderName: map['senderName'] as String,
      text: map['text'] as String,
      time: map['time'] as String,
      isMe: map['isMe'] as bool,
      senderRole: UserRole.values.byName(map['senderRole'] as String),
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
  final String recipientId;
  final UserRole recipientRole;
  final String? relatedRecordId;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.type,
    this.isRead = false,
    required this.recipientId,
    required this.recipientRole,
    this.relatedRecordId,
    required this.createdAt,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    String? timeLabel,
    NotificationType? type,
    bool? isRead,
    String? recipientId,
    UserRole? recipientRole,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timeLabel: timeLabel ?? this.timeLabel,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      recipientId: recipientId ?? this.recipientId,
      recipientRole: recipientRole ?? this.recipientRole,
      relatedRecordId: relatedRecordId,
      createdAt: createdAt,
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
      'recipientId': recipientId,
      'recipientRole': recipientRole.name,
      'relatedRecordId': relatedRecordId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory NotificationItem.fromMap(Map<dynamic, dynamic> map) =>
      NotificationItem(
        id: map['id'] as String,
        title: map['title'] as String,
        message: map['message'] as String,
        timeLabel: map['timeLabel'] as String,
        type: NotificationType.values.byName(map['type'] as String),
        isRead: map['isRead'] as bool,
        recipientId: map['recipientId'] as String,
        recipientRole: UserRole.values.byName(map['recipientRole'] as String),
        relatedRecordId: map['relatedRecordId'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      );
}
