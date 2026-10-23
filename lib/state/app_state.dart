import 'package:flutter/material.dart';

import '../models/models.dart';

class AppState extends ChangeNotifier {
  UserRole _role = UserRole.owner;
  int _ownerNavIndex = 0;
  int _sitterNavIndex = 0;
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';
  SitterListing? _selectedSitter;

  UserRole get role => _role;
  int get ownerNavIndex => _ownerNavIndex;
  int get sitterNavIndex => _sitterNavIndex;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  SitterListing? get selectedSitter => _selectedSitter;

  void setRole(UserRole newRole) {
    _role = newRole;
    notifyListeners();
  }

  void setOwnerNavIndex(int index) {
    _ownerNavIndex = index;
    notifyListeners();
  }

  void setSitterNavIndex(int index) {
    _sitterNavIndex = index;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectSitter(SitterListing? sitter) {
    _selectedSitter = sitter;
    notifyListeners();
  }

  // Dog data
  Dog _currentDog = Dog(
    id: 'dog_1',
    name: 'Barley',
    breed: 'Golden Retriever',
    ageYears: 2,
    weightKg: 28.5,
    gender: 'Erkek',
    microchip: '900215002941842',
    photoPath: 'assets/images/barley.jpg',
    allergyNote: 'Tavuk proteini alerjisi — Yalnızca kuzu etli mama veriniz.',
    behaviorNote: 'İnsanlara ve diğer köpeklere karşı son derece uysal, oyuncu ve enerjik.',
    clinicName: 'Kadıköy Veteriner Polikliniği',
    clinicPhone: '+90 216 345 67 89',
    vaccinations: [
      Vaccination(
        id: 'v_1',
        title: 'Karma Aşı (DHPPi+L)',
        dueDate: '26 Ekim 2026',
        status: VaccineStatus.upcoming,
        vetName: 'Dr. Selin Bulut',
      ),
      Vaccination(
        id: 'v_2',
        title: 'Kuduz Aşısı (Rabies)',
        dueDate: '14 Haziran 2026',
        status: VaccineStatus.completed,
        vetName: 'Dr. Selin Bulut',
        completionDate: '14 Haziran 2026',
      ),
      Vaccination(
        id: 'v_3',
        title: 'İç & Dış Parazit Tedavisi',
        dueDate: '02 Eylül 2026',
        status: VaccineStatus.completed,
        vetName: 'Dr. Selin Bulut',
        completionDate: '02 Eylül 2026',
      ),
      Vaccination(
        id: 'v_4',
        title: 'Kennel Cough (Bronşin)',
        dueDate: '15 Kasım 2026',
        status: VaccineStatus.upcoming,
        vetName: 'Dr. Selin Bulut',
      ),
    ],
  );

  Dog get currentDog => _currentDog;

  void updateDog(Dog updated) {
    _currentDog = updated;
    notifyListeners();
  }

  // Sitter listings
  final List<SitterListing> _sitters = [
    SitterListing(
      id: 'sitter_1',
      name: 'Ayşe Yılmaz',
      facilityTitle: 'Mutlu Patiler Butik Köpek Oteli',
      category: 'Köpek Oteli',
      rating: 4.9,
      reviewsCount: 128,
      pricePerUnit: 450,
      unitLabel: 'gece',
      location: 'Caddebostan, Kadıköy',
      distanceKm: 1.2,
      imagePath: 'assets/images/ayse.jpg',
      galleryPaths: [
        'assets/images/hotel_garden.jpg',
        'assets/images/ayse.jpg',
        'assets/images/barley.jpg',
      ],
      bio: '7 yıldır profesyonel evcil hayvan bakım uzmanıyım. Müstakil bahçeli evimizde misafirlerimize 7/24 birebir ilgi, geniş çim oyun alanı ve sevgi dolu bir konaklama sunuyoruz.',
      amenities: [
        'Geniş Çim Bahçe',
        '7/24 Kamera Takibi',
        'Günde 3 Kez Yürüyüş',
        'Klimalı Süitler',
        'Veteriner Protokolü',
      ],
      isVerified: true,
    ),
    SitterListing(
      id: 'sitter_2',
      name: 'Mert Demir',
      facilityTitle: 'ProDog Profesyonel Gezdirici & Eğitmen',
      category: 'Köpek Gezdirme',
      rating: 5.0,
      reviewsCount: 84,
      pricePerUnit: 250,
      unitLabel: 'saat',
      location: 'Moda Sahil, Kadıköy',
      distanceKm: 2.1,
      imagePath: 'assets/images/mert.jpg',
      galleryPaths: [
        'assets/images/mert.jpg',
        'assets/images/hotel_garden.jpg',
      ],
      bio: 'Sertifikalı köpek eğitmeni ve profesyonel gezdirici. Köpeğinizin fiziksel ve mental enerjisini atabileceği güvenli, tempolu ve eğlenceli yürüyüş seansları düzenliyorum.',
      amenities: [
        'Canlı GPS Takibi',
        'Pozitif Pekiştirme',
        'Birebir Yürüyüş',
        'Fotoğraflı Bildirim',
      ],
      isVerified: true,
    ),
    SitterListing(
      id: 'sitter_3',
      name: 'Selin & Can Kaya',
      facilityTitle: 'Pati Köşkü Gündüz Bakım Evi',
      category: 'Gündüz Bakımı',
      rating: 4.8,
      reviewsCount: 62,
      pricePerUnit: 350,
      unitLabel: 'gün',
      location: 'Fenerbahçe, Kadıköy',
      distanceKm: 3.4,
      imagePath: 'assets/images/hotel_garden.jpg',
      galleryPaths: [
        'assets/images/hotel_garden.jpg',
        'assets/images/ayse.jpg',
      ],
      bio: 'Siz işteyken dostunuz evde yalnız kalmasın. Sosyalleşme seansları, dinlenme odaları ve özel beslenme takibiyle güvenli gündüz bakımı sağlıyoruz.',
      amenities: [
        'Sosyal Oyun Grubu',
        'İlaç & Diyet Takibi',
        'Ses Yalıtımlı Dinlenme',
      ],
      isVerified: true,
    ),
  ];

  List<SitterListing> get sitters {
    if (_selectedCategory == 'Tümü' && _searchQuery.isEmpty) {
      return _sitters;
    }
    return _sitters.where((s) {
      final matchesCategory =
          _selectedCategory == 'Tümü' || s.category == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.facilityTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Bookings list (shared between Owner & Sitter views)
  final List<BookingRequest> _bookings = [
    BookingRequest(
      id: 'book_101',
      sitterId: 'sitter_1',
      sitterName: 'Ayşe Yılmaz',
      sitterPhoto: 'assets/images/ayse.jpg',
      petName: 'Barley',
      petBreed: 'Golden Retriever',
      serviceTitle: 'Köpek Oteli — 2 Gece Konaklama',
      startDate: DateTime(2026, 10, 24),
      endDate: DateTime(2026, 10, 26),
      totalPrice: 950.0,
      careNotes: 'Barley tavuk alerjisine sahip, kendi maması çantada teslim edilecektir. Akşam 19:00 civarı teslim edeceğiz.',
      status: BookingStatus.pending,
    ),
    BookingRequest(
      id: 'book_100',
      sitterId: 'sitter_2',
      sitterName: 'Mert Demir',
      sitterPhoto: 'assets/images/mert.jpg',
      petName: 'Barley',
      petBreed: 'Golden Retriever',
      serviceTitle: 'Caddebostan Sahil Parkı Yürüyüşü',
      startDate: DateTime(2026, 10, 23, 14, 0),
      endDate: DateTime(2026, 10, 23, 15, 0),
      totalPrice: 250.0,
      careNotes: 'Tempolu sahil yürüyüşü, bol su molası.',
      status: BookingStatus.confirmed,
    ),
  ];

  List<BookingRequest> get bookings => _bookings;

  void addBooking(BookingRequest newBooking) {
    _bookings.insert(0, newBooking);
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index].status = newStatus;
      notifyListeners();
    }
  }

  // Interactive Demo Chat Messages
  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      id: 'm1',
      senderName: 'Mert Demir',
      text: 'Merhaba Aygen Hanım! Barley ile Caddebostan Sahil Parkı girişinde buluştuk.',
      time: '14:02',
      isMe: false,
    ),
    ChatMessage(
      id: 'm2',
      senderName: 'Aygen',
      text: 'Harika Mert Bey! Enerjisi yerindedir umarım, sabah biraz heyecanlıydı.',
      time: '14:05',
      isMe: true,
    ),
    ChatMessage(
      id: 'm3',
      senderName: 'Mert Demir',
      text: 'Çok neşeli! Çim alanda biraz koştuk, şimdi gölgelikte su molası veriyoruz. Canlı takip üzerinden konumumuzu izleyebilirsiniz 🐾',
      time: '14:18',
      isMe: false,
    ),
  ];

  List<ChatMessage> get chatMessages => _chatMessages;

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    _chatMessages.add(
      ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'Aygen',
        text: text.trim(),
        time:
            '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        isMe: true,
      ),
    );
    notifyListeners();
  }
}

// InheritedWidget wrapper for AppState access
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}
