enum UserRole { owner, sitter }

enum VaccineStatus { completed, upcoming, overdue }

class Vaccination {
  final String id;
  final String title;
  final String dueDate;
  final VaccineStatus status;
  final String vetName;
  final String? completionDate;

  Vaccination({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.status,
    required this.vetName,
    this.completionDate,
  });
}

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

  Dog({
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
      id: id,
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
}

class SitterListing {
  final String id;
  final String name;
  final String facilityTitle;
  final String category; // 'Köpek Oteli', 'Köpek Gezdirme', 'Gündüz Bakımı'
  final double rating;
  final int reviewsCount;
  final double pricePerUnit;
  final String unitLabel; // 'gece', 'saat', 'gün'
  final String location;
  final double distanceKm;
  final String imagePath;
  final List<String> galleryPaths;
  final String bio;
  final List<String> amenities;
  final bool isVerified;

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
    required this.galleryPaths,
    required this.bio,
    required this.amenities,
    this.isVerified = true,
  });
}

enum BookingStatus { pending, confirmed, rejected, completed }

class BookingRequest {
  final String id;
  final String sitterId;
  final String sitterName;
  final String sitterPhoto;
  final String petName;
  final String petBreed;
  final String serviceTitle;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String careNotes;
  BookingStatus status;

  BookingRequest({
    required this.id,
    required this.sitterId,
    required this.sitterName,
    required this.sitterPhoto,
    required this.petName,
    required this.petBreed,
    required this.serviceTitle,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.careNotes,
    this.status = BookingStatus.pending,
  });
}

class ChatMessage {
  final String id;
  final String senderName;
  final String text;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.text,
    required this.time,
    required this.isMe,
  });
}
