import '../../data/models/money.dart';

abstract final class AppStrings {
  static const missingListingTitle = 'İlan kaydı okunamıyor';
  static const missingListingBody =
      'Kayıt bulunamadı veya bozulmuş. Asıl veriler korunuyor. Hesap ekranından başka bir hesabı açabilirsiniz.';
  static const openAccounts = 'Hesap ekranına git';
  static const photoIntentCleanupFailed =
      'Fotoğraf kaydedildi; seçim kaydı sonraki açılışta yeniden kontrol edilecek.';
  static const archivedNotifications = 'Bildirim arşivi';
  static const photoCleanupFailed =
      'Fotoğraf kaydedildi. Eski dosya henüz temizlenemedi.';
  static const retry = 'Yeniden dene';
  static const startupErrorTitle = 'Kayıtlar açılamadı';
  static const startupErrorBody =
      'Yerel veriler açılırken bir hata oluştu. Kayıtlarınız silinmedi. Tekrar deneyebilirsiniz.';
  static String invalidRecordsNotice(int count) =>
      '$count kayıt okunamadı. Asılları korunuyor.';
  static const chatTitle = 'Konuşma';
  static const olderMessages = 'Önceki mesajlar';
  static const recentMessages = 'Son mesajlar / Yeniden dene';
  static const previousPage = 'Önceki sayfa';
  static const nextPage = 'Sonraki sayfa';
  static String pageInfo(int page, int total) => '$page / $total';
  static const noHealthRecordsTitle = 'Aşı kaydı bulunmuyor';
  static const noHealthRecordsBody =
      'Sağlık kartından aşı kayıtlarını ekleyebilirsiniz.';
  static const unknownVaccineDateTitle = 'Aşı tarihini kontrol edin';
  static const unknownVaccineDateBody =
      'Bu kayıtta tarih belirtilmedi; tamamlanmış kabul edilmedi.';
  static const dateUnknown = 'Tarih bilinmiyor';
  static const statusOverdue = 'Gecikti';
  static const notProvided = 'Bilgi girilmedi';
  static const noNutritionPlan =
      'Kayıtlı beslenme planı yok. Veterinerinizin verdiği planı ekleyebilirsiniz.';
  static const nutritionPlanLabel =
      'Veteriner tarafından verilen beslenme planı';
  static const veterinarianNameLabel = 'Veteriner adı (isteğe bağlı)';
  static const invalidVaccineDate = 'Geçerli bir aşı tarihi seçin.';
  static const invalidPetFields =
      'Ad, ırk, geçerli yaş ve ağırlık bilgilerini kontrol edin.';
  static const duplicateMicrochip =
      'Bu mikroçip kimliği başka bir kayıtta kullanılıyor.';
  static const invalidAuthFields =
      'Geçerli bir e-posta ve en az 8 karakterli demo şifresi girin.';
  static const invalidEmail = 'Geçerli bir e-posta adresi girin.';
  static const upcomingReservationTitle = 'Sıradaki Rezervasyon';
  static const viewReservation = 'Rezervasyonu gör';
  static const viewRequests = 'Taleplerimi gör';
  static const pendingReservationSubtitle =
      'Onay bekleyen talebiniz var. Son durumu Taleplerim ekranından takip edebilirsiniz.';
  static String pendingReservations(int count) => '$count talep onay bekliyor';
  static String otherReservations(int count) => 'Diğer $count rezervasyonu gör';
  static String trackingPair(String sitter, String pet) => '$sitter & $pet';
  static String overdueVaccineTitle(String title) => 'Geciken aşı: $title';
  static String vaccineDays(int days) => days < 0
      ? '${-days} gün gecikti'
      : days == 0
      ? 'Bugün'
      : '$days gün kaldı';
  static const unitNight = 'gece';
  static const unitDay = 'gün';
  static const unitHour = 'saat';
  static const bookingPriceChanged =
      'İlanın ücreti değişti. Güncel tutarı kontrol edip tekrar gönderin.';
  static const bookingSaveFailed =
      'İşlem kaydedilemedi. Bilgileriniz korunuyor; tekrar deneyebilirsiniz.';
  static const invalidBookingAction =
      'Bu rezervasyon için işlem artık uygun değil. Listeyi yenileyin.';
  static const invalidPrice = 'Geçerli bir ücret girin (0–1.000.000 TL arası).';
  static const statusCancelled = 'İptal Edildi';
  static const completeService = 'Hizmeti tamamla';
  static const serviceCompleted = 'Hizmet tamamlandı.';
  static const serviceStartTime = 'Başlangıç saati';
  static const serviceDuration = 'Yürüyüş süresi';
  static const capacityLabel = 'Aynı anda kabul edilen köpek sayısı';
  static const invalidCapacity = 'Kapasite 1 ile 100 arasında olmalıdır.';
  static const awaitingCompletionTitle = 'Tamamlanmayı bekleyen hizmetler';
  static const saving = 'Kaydediliyor…';
  static String durationHours(int hours) => '$hours $unitHour';
  static String startTimeLabel(String time) => '$serviceStartTime: $time';
  static String bookingPeriod(
    DateTime start,
    DateTime end, {
    bool hourly = false,
    bool dayCare = false,
  }) {
    final shownEnd = dayCare
        ? end.subtract(const Duration(microseconds: 1))
        : end;
    final dates = formatDateRange(start, shownEnd);
    if (!hourly) return dates;
    String clock(DateTime d) =>
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$dates · ${clock(start)}–${clock(end)}';
  }

  static const notificationDeliveryFailed =
      'İşlem kaydedildi, ancak bildirimi oluşturmak mümkün olmadı.';
  static const noPetsTitle = 'Henüz kayıtlı köpeğiniz yok';
  static const noPetsBody =
      'Profil ve sağlık kayıtlarını yönetmek veya rezervasyon yapmak için köpeğinizi ekleyin.';
  static const addFirstPet = 'İlk köpeğimi ekle';
  static const ownerDashboardSubtitle =
      'Dostunuzun bakım planını buradan takip edin.';
  static String notificationTime(DateTime createdAt, DateTime now) {
    final elapsed = now.difference(createdAt);
    if (elapsed.inMinutes < 1) return timeNow;
    if (elapsed.inMinutes < 60) return '${elapsed.inMinutes} dk önce';
    if (elapsed.inHours < 24) return '${elapsed.inHours} saat önce';
    return formatShortDate(createdAt);
  }

  // Brand & App
  static const String appName = 'PawCare';
  static const String appTitle = 'PawCare — Evcil Hayvan Yönetimi';
  static const String splashTagline = 'Şefkatli & Güvenilir Köpek Bakımı';
  static const String welcomeHeroBadge = 'Şefkatli & Güvenilir Bakım';
  static const String welcomeTitle = 'Dostunuz için en güvenilir eller.';
  static const String welcomeSubtitle =
      'Sakin, özenli ve profesyonel köpek bakımı, otel konaklaması ve yürüyüş hizmetlerini keşfedin.';
  static const String selectDemoRole = 'Demo Rolünü Seçin';
  static const String startAsOwnerTitle = 'Köpek Sahibi Olarak Başla';
  static const String startAsOwnerSubtitle =
      'Köpek profili, aşı takibi ve güvenilir bakıcı rezervasyonu';
  static const String switchToSitterPanelTitle = 'Hizmet Veren Paneline Geç';
  static const String switchToSitterPanelSubtitle =
      'Gelen rezervasyon talepleri, misafir köpekler ve kazanç yönetimi';

  // Bottom Navigation
  static const String navHome = 'Ana Sayfa';
  static const String navExplore = 'Keşfet';
  static const String navMyDogs = 'Köpeklerim';
  static const String navMyRequests = 'Taleplerim';
  static const String navProfile = 'Profil';
  static const String navDashboard = 'Panel';
  static const String navMyListing = 'İlanım';
  static const String navCalendar = 'Takvim';
  static const String navReviews = 'Yorumlar';

  // Common Buttons & Labels
  static const String cancel = 'Vazgeç';
  static const String save = 'Kaydet';
  static const String ok = 'Tamam';
  static const String close = 'Kapat';
  static const String apply = 'Uygula';
  static const String reset = 'Sıfırla';
  static const String seeAll = 'Hepsi';
  static const String notifications = 'Bildirimler';
  static const String markAllRead = 'Tümünü Okundu İşaretle';
  static const String timeNow = 'Şimdi';
  static const String roleOwner = 'Köpek Sahibi';
  static const String roleSitter = 'Hizmet Veren';
  static const String roleOwnerMode = 'Sahip Modu';
  static const String defaultOwnerFallbackName = 'Aygen';
  static const String defaultOwnerFullName = 'Aygen Y.';
  static const String defaultOwnerEmail = 'aygen@pawcare.com';
  static const String defaultSitterFullName = 'Ayşe Yılmaz';
  static const String defaultSitterEmail = 'ayse@mutlupatiler.com';

  // Status Badges
  static const String statusConfirmed = 'Onaylandı';
  static const String statusPending = 'Beklemede';
  static const String statusRejected = 'Reddedildi';
  static const String statusCompleted = 'Tamamlandı';
  static const String statusUpcoming = 'Yaklaşıyor';

  // Calendar
  static const List<String> monthNames = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  static const List<String> weekDays = <String>[
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  static String formatShortDate(DateTime date) =>
      '${date.day} ${monthNames[date.month - 1]} ${date.year}';

  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return formatShortDate(start);
    }
    if (start.year == end.year && start.month == end.month) {
      return '${start.day} - ${end.day} ${monthNames[end.month - 1]} ${end.year}';
    }
    if (start.year == end.year) {
      return '${start.day} ${monthNames[start.month - 1]} - ${end.day} ${monthNames[end.month - 1]} ${end.year}';
    }
    return '${formatShortDate(start)} - ${formatShortDate(end)}';
  }

  static String currencyAmount(num amount) => Money.format(amount);
  static String ratingAndReviewCount(double rating, int count) =>
      '$rating ($count)';
  static String nameAndLocation(String name, String location) =>
      '$name • $location';
  static String categoryAndLocation(String category, String location) =>
      '$category • $location';
  static String priceCalculation(double price, int units, String unit) =>
      '${Money.format(price)} x $units $unit';
  static String contactWithPet(String name, String petName) =>
      '$name & $petName';
  static String unitSuffix(String unit) => '/$unit';
  static String galleryPosition(int current, int total) => '$current / $total';

  // Auth (Login & SignUp)
  static const String authDemoBadge = 'PawCare Demo';
  static const String loginWelcomeTitle = 'Tekrar Hoş Geldin';
  static const String loginWelcomeSubtitle = 'PawCare hesabına giriş yap.';
  static const String loginButton = 'Giriş Yap';
  static const String createAccountButton = 'Hesap Oluştur';
  static const String emailLabel = 'E-posta';
  static const String emailAddressLabel = 'E-posta Adresi';
  static const String emailHint = 'ornek@email.com';
  static const String passwordLabel = 'Şifre';
  static const String passwordMaskedHint = '••••••••';
  static const String passwordMinLengthHint = 'En az 8 karakter';
  static const String confirmPasswordLabel = 'Şifre Tekrar';
  static const String confirmPasswordHint = 'Şifrenizi tekrar giriniz';
  static const String fullNameLabel = 'Ad Soyad';
  static const String fullNameHint = 'Adınız ve Soyadınız';
  static const String noAccountPrefix = 'Hesabın yok mu? ';
  static const String alreadyHaveAccountPrefix = 'Zaten hesabın var mı? ';
  static const String loginSuccessSnack =
      'Hoş geldiniz! Demo hesabı ile giriş yapıldı.';
  static const String signUpBadge = 'Yeni Kayıt';
  static const String signUpTitle = 'PawCare\'e Katıl';
  static const String signUpSubtitle =
      'Sevgi dolu bir evcil hayvan topluluğunun parçası olun.';
  static const String selectAccountRole = 'Hesap Rolünüzü Seçin';
  static const String signUpSuccessSnack =
      'PawCare\'e hoş geldiniz! Hesabınız oluşturuldu.';
  static const String authErrorEmptyFields = 'Lütfen tüm alanları doldurunuz.';
  static const String profileEmailInUse =
      'Bu e-posta adresi başka bir yerel hesaba ait.';
  static const String authErrorPasswordMismatch =
      'Şifreler birbiriyle eşleşmiyor.';

  // Owner Home
  static String greetingOwner(String ownerName) => 'Merhaba, $ownerName 👋';
  static String ageYearsBadge(int ageYears) => '$ageYears Yaş';
  static String weightKgValue(double weightKg) => '$weightKg kg';
  static String breedAndWeight(String breed, double weightKg) =>
      '$breed • $weightKg kg';
  static String breedAndAge(String breed, int ageYears) =>
      '$breed • $ageYears Yaş';
  static String breedAgeWeight(String breed, int ageYears, double weightKg) =>
      '$breed • $ageYears Yaş • $weightKg kg';
  static String dogChipLabel(String name, String breed) => '$name ($breed)';
  static const String healthCardChip = 'Sağlık Kartı';
  static const String editProfileChip = 'Profili Düzenle';
  static const String vaccineCardButton = 'Aşı Kartı';
  static String vaccineTimeTitle(String vaccineTitle) =>
      '$vaccineTitle Zamanı!';
  static const String allVaccinesCompletedTitle = 'Tüm Aşılar Tamamlandı!';
  static String vaccineAppointmentSubtitle(String dueDate, String vetName) =>
      '$dueDate • $vetName randevusu';
  static const String noUpcomingVaccineSubtitle =
      'Yaklaşan zorunlu aşı randevusu bulunmuyor.';
  static const String todaysReservationTitle = 'Günün Rezervasyonu';
  static const String liveWalkingBadge = 'Yürüyüşte • Canlı';
  static const String activeReservationBadge = 'Rezervasyon Aktif';
  static const String noActiveReservationTitle =
      'Bugün için onaylı aktif rezervasyonunuz bulunmuyor.';
  static const String noActiveReservationSubtitle =
      'Dostunuz için güvenilir otel, gündüz bakımı veya yürüyüş hizmetlerini hemen inceleyebilirsiniz.';
  static const String exploreSittersButton = 'Hizmetleri Keşfet';
  static const String defaultWalkerName = 'Mert Demir';
  static const String defaultWalkLocation = 'Caddebostan Sahil Parkı';
  static const String liveTrackingButton = 'Takip Demosu';
  static const String chatButton = 'Sohbet';
  static const String featuredServicesTitle = 'Öne Çıkan Hizmetler';
  static String pricePerUnitShort(double price, String unitLabel) =>
      '${Money.format(price)}/$unitLabel';

  // Explore / Discovery
  static const String categoryAll = 'Tümü';
  static const String categoryHotel = 'Köpek Oteli';
  static const String categoryWalking = 'Köpek Gezdirme';
  static const String categoryDaycare = 'Gündüz Bakımı';
  static const List<String> exploreCategories = <String>[
    categoryAll,
    categoryHotel,
    categoryWalking,
    categoryDaycare,
  ];
  static const String exploreHeaderTitle = 'Hizmet Keşfet';
  static const String exploreSearchHint =
      'Bakıcı, otel veya ilçe ara (örn. Kadıköy)...';
  static const String advancedFilterTitle = 'Gelişmiş Filtreleme';
  static const budgetUnlimited = 'Ücret sınırı yok';
  static String maxPriceLabel(double? maxPrice) => maxPrice == null
      ? budgetUnlimited
      : 'Maksimum Ücret: ${Money.format(maxPrice)}';
  static String budgetChipLabel(double budget) => '₺${budget.toInt()} ve altı';
  static const String sortCriteriaTitle = 'Sıralama Ölçütü';
  static const String sortByLowestPriceLabel = 'En Düşük Fiyata Göre Sırala';
  static const String defaultCityLocation = 'İstanbul';
  static const String exploreEmptyTitle = 'Eşleşen Hizmet Bulunamadı';
  static const String exploreEmptySubtitle =
      'Arama kriterlerinize veya seçili bütçe filtresine uygun bakıcı bulunamadı.';
  static const String clearFiltersButton = 'Filtreleri Temizle';
  static String exploreResultsCount({
    required int count,
    required String searchQuery,
    required String selectedCategory,
  }) {
    final trimmed = searchQuery.trim();
    if (trimmed.isNotEmpty) {
      return '"$trimmed" için $count Hizmet Bulundu';
    }
    if (selectedCategory != categoryAll) {
      return '$selectedCategory Kategorisinde $count Hizmet Bulundu';
    }
    return 'İstanbul Genelinde $count Hizmet Bulundu';
  }

  static String sitterNameLocationDistance(
    String name,
    String location,
    double distanceKm,
  ) => '$name • $location ($distanceKm km)';
  static const String inspectAndRequestButton = 'İncele ve Talep Gönder';

  // Sitter Detail & Booking Request
  static const String dateRangeSelectionTitle = 'Tarih Aralığı Seçimi';
  static const String bookingRangeUnavailableError =
      'Lütfen geçmiş veya dolu günleri içermeyen geçerli bir tarih aralığı seçin.';
  static const String specialCareNotesTitle = 'Özel Bakım ve Beslenme Notu';
  static const String specialCareNotesHint =
      'Alerjiler, rutinler, ilaçlar veya özel istekler...';
  static const String sendBookingRequestButton = 'Rezervasyon Talebi Gönder';
  static const String aboutFacilityTitle = 'Tesis Hakkında';
  static const String facilityAmenitiesTitle = 'Tesis Olanakları';
  static String reviewsCountLabel(int count) => ' ($count değerlendirme)';
  static const String bookingDogSelectionTitle = 'Rezervasyon Yapılacak Köpek';
  static const String pawCareServiceFeeLabel = 'PawCare Hizmet Bedeli';
  static const String totalAmountLabel = 'Toplam Tutar';
  static const String requestSentTitle = 'Talebiniz İletildi!';
  static String requestSentBody(String sitterName) =>
      '$sitterName talebinizi inceleyip onaylayacaktır. Hizmet Veren paneline geçerek talebi görüntüleyebilirsiniz.';
  static String bookingServiceSummary(
    String category,
    int units,
    String unitLabel,
  ) => '$category — $units $unitLabel Rezervasyon';

  // Pets / Dog Profile & Modals
  static const String dogProfileHeaderTitle = 'Köpek Profili & Sağlık';
  static const String photoUpdatedSnack =
      'Köpek profil fotoğrafı kalıcı olarak güncellendi.';
  static String microchipSubtitle(String breed, String microchip) =>
      '$breed • Mikroçip: $microchip';
  static const String statAgeLabel = 'Yaş';
  static const String statWeightLabel = 'Ağırlık';
  static const String statGenderLabel = 'Cinsiyet';
  static const String addNewDogButton = 'Yeni Köpek Ekle';
  static const String criticalHealthWarningTitle =
      'Kritik Sağlık & Alerji Uyarısı';
  static const String vaccineScheduleSectionTitle = 'Aşı Takvimi & Kayıtlar';
  static const String viewSummaryButton = 'Özeti Gör';
  static const String nutritionAndBehaviorTitle =
      'Beslenme & Davranış Özellikleri';
  static const String dailyNutritionPlanTitle = 'Günlük Beslenme Planı';
  static const String socialBehaviorTitle = 'Sosyal Davranış & Karakter';
  static const String responsibleVetClinicTitle = 'Sorumlu Veteriner Kliniği';
  static String vetCallContactName(String clinicName) => clinicName;
  static const String vetEmergencySubtitle =
      'Veteriner Kliniği Acil & Randevu Hattı';
  static const String callNowButton = 'Hemen Ara';
  static const String editDogModalTitle = 'Köpek Profilini Düzenle';
  static String dogProfileUpdatedSnack(String dogName) =>
      '$dogName profil bilgileri güncellendi.';
  static String dogAddedSnack(String dogName) => '$dogName başarıyla eklendi!';
  static const String fieldDogName = 'Köpek Adı';
  static const String fieldBreed = 'Irk / Cins';
  static const String fieldWeightKg = 'Kilo (kg)';
  static const String fieldMicrochip = 'Mikroçip Numarası';
  static const String fieldAllergyNote = 'Alerji & Sağlık Notu';
  static const String fieldBehaviorNote = 'Beslenme & Davranış';
  static const String fieldVetClinic = 'Veteriner Kliniği';
  static const String fieldClinicPhone = 'Klinik Telefon';
  static String digitalIdentityTitle(String dogName) =>
      '$dogName — Dijital Kimlik';
  static String clinicPrefix(String clinicName) => 'Klinik: $clinicName';
  static String healthCardModalTitle(String dogName) =>
      '$dogName — Sağlık Kartı';
  static const String vaccineAndTreatmentRecordsTitle =
      'Aşı ve Tedavi Kayıtları';
  static const String addVaccineButton = 'Yeni Aşı / Tedavi Ekle';
  static String vaccineDateAndVet(String dueDate, String vetName) =>
      'Tarih: $dueDate • $vetName';
  static const String fieldVaccineTitle = 'Aşı / Tedavi Adı';
  static const String fieldPlannedDate = 'Planlanan Tarih';
  static const String fieldVetName = 'Veteriner Hekim';
  // Notifications (Dynamic Controller Messages)
  static const String notifBookingCancelledTitle =
      'Rezervasyon Talebi İptal Edildi';
  static String notifBookingCancelledBody(String sitterName, String petName) =>
      '$sitterName için oluşturulan $petName talebi iptal edildi.';
  static const String notifBookingCreatedTitle =
      'Rezervasyon Talebi Oluşturuldu';
  static String notifBookingCreatedBody(
    String sitterName,
    String facilityTitle,
    String dogName,
  ) => '$sitterName ($facilityTitle) için $dogName adına talebiniz iletildi.';
  static const String notifDogUpdatedTitle = 'Köpek Profili Güncellendi';
  static String notifDogUpdatedBody(String dogName) =>
      '$dogName profil ve sağlık bilgileri kaydedildi.';
  static const String notifDogAddedTitle = 'Yeni Köpek Eklendi';
  static String notifDogAddedBody(String dogName, String breed) =>
      '$dogName ($breed) başarıyla profilinize eklendi.';
  static const String notifVaccineAddedTitle = 'Aşı Hatırlatıcısı Eklendi';
  static String notifVaccineAddedBody(
    String dogName,
    String vaccineTitle,
    String dueDate,
  ) => '$dogName için $vaccineTitle ($dueDate) kaydedildi.';
  static const String notifBookingStatusUpdatedTitle =
      'Rezervasyon Durumu Güncellendi';
  static const String statusWordApproved = 'onaylandı';
  static const String statusWordRejected = 'reddedildi';
  static const String statusWordCompleted = 'tamamlandı';
  static String notifBookingStatusUpdatedBody(
    String petName,
    String serviceTitle,
    String statusWord,
  ) => '$petName için $serviceTitle talebi $statusWord.';

  // Owner Bookings
  static const String myBookingRequestsTitle = 'Rezervasyon Taleplerim';
  static const String myBookingRequestsSubtitle =
      'Gönderdiğiniz tüm bakım ve otel talepleri';
  static const String noBookingsYet = 'Henüz rezervasyon bulunmuyor.';
  static String bookingPetAndTotalLabel(String petName) =>
      'Köpek: $petName • Toplam Ücret';
  static const String writeToSitterButton = 'Bakıcıya Yaz';
  static const String cancelRequestButton = 'Talebi İptal Et';

  // Provider / Sitter Dashboard & Sub-tabs
  static const String kpiPendingTitle = 'Bekleyen';
  static const String kpiPendingSubtitle = 'Talep';
  static const String kpiConfirmedTitle = 'Onaylı';
  static const String kpiConfirmedSubtitle = 'Rezervasyon';
  static const String kpiEarningsTitle = 'Onaylı toplam';
  static const String kpiEarningsSubtitle = 'Bu ay · brüt';
  static const String incomingRequestsTitle = 'Yeni Gelen Talepler';
  static const String allRequestsAnsweredTitle = 'Tüm talepler yanıtlandı!';
  static const String noPendingRequestsSubtitle =
      'Şu anda bekleyen yeni rezervasyon talebi bulunmuyor.';
  static const String requestRejectedSnack = 'Talep reddedildi.';
  static String requestApprovedSnack(String petName) =>
      '$petName için rezervasyon başarıyla onaylandı!';
  static String ownerAndDistrictLabel(String ownerName) =>
      'Sahibi: $ownerName • Kadıköy';
  static String careNotesPrefix(String notes) => 'Not: $notes';
  static const String rejectButton = 'Reddet';
  static const String approveButton = 'Onayla';
  static const String messageOwnerButton = 'Sahibine Mesaj Gönder';
  static const String activeAndUpcomingGuestsTitle =
      'Aktif & Yaklaşan Konuklar';
  static const String noActiveGuestsTitle =
      'Şu anda aktif veya onaylı konuk bulunmuyor.';
  static const String noActiveGuestsSubtitle =
      'Yeni gelen talepleri onayladığınızda konuklar burada listelenir.';
  static const String myListingAndPricesTitle = 'İlanım & Fiyatlarım';
  static String unitPriceLabel(double price, String unitLabel) =>
      'Birim Ücret ($unitLabel): ${Money.format(price)}';
  static String fieldUnitPrice(String unitLabel) =>
      'Birim Ücret ($unitLabel / ₺)';
  static const String editListingAndPriceButton = 'İlanı ve Ücreti Düzenle';
  static const String editListingModalTitle = 'İlanı & Fiyatı Düzenle';
  static const String listingUpdatedSnack =
      'İlan ve fiyat bilgileri güncellendi.';
  static const String fieldFacilityTitle = 'Tesis / İlan Başlığı';
  static const String fieldDistrictLocation = 'İlçe / Konum';
  static const String fieldFacilityBio = 'Tesis Açıklaması';
  static const String availabilityCalendarTitle = 'Müsaitlik Takvimi';
  static const String availabilityCalendarHint =
      'Dolu olarak işaretlemek istediğiniz günlere dokunun.';
  static const String reviewsTabTitle = 'Değerlendirmeler';
  static const String reviewsSummaryScore = 'Örnek değerlendirmeler';
  static const String reviewsSummarySubtitle =
      'Aşağıdaki yorumlar örnektir; bu hesabın müşteri değerlendirmeleri değildir.';
  static const List<(String, String, String)> sitterReviewsList =
      <(String, String, String)>[
        (
          'Aygen Y. (Barley)',
          '20 Ekim 2026',
          'Barley tavuk alerjisine rağmen çok özenle beslendi, her gün fotoğraf ve video gönderildi. Çok teşekkürler!',
        ),
        (
          'Kerem T. (Max)',
          '14 Ekim 2026',
          'Bahçe alanı tertemiz ve güvenli. Max eve döndüğünde çok mutlu ve enerjikti.',
        ),
        (
          'Zeynep A. (Luna)',
          '02 Ekim 2026',
          'Veteriner kontrolü ve kamera izleme olanağı sayesinde gözümüz hiç arkada kalmadı.',
        ),
      ];

  // Profile & Modals
  static const String accountAndProfileTitle = 'Hesap & Profil';
  static const String settingsAndPreferencesTitle = 'Ayarlar & Tercihler';
  static const String sitterProfileRoleSubtitle = 'Hizmet Veren';
  static String ownerProfileRoleSubtitle(int count, String dogNames) =>
      'Köpek Sahibi ($count Kayıtlı Köpek: $dogNames)';
  static const String darkKhakiThemeTitle = 'Koyu Yeşil (Haki) Tema';
  static const String darkThemeActiveSubtitle = 'Haki Koyu Tema Aktif';
  static const String lightThemeActiveSubtitle = 'Açık Tema Aktif';
  static const phoneNotProvided = 'Telefon bilgisi eklenmemiş';
  static const String notificationPreferencesTitle = 'Bildirimler';
  static const String switchActiveRoleTitle =
      'Aktif Rolü Değiştir (Sahip / Hizmet Veren)';
  static const String paymentMethodsTitle = 'Ödeme Yöntemleri';
  static const String privacyAndSecurityTitle = 'Gizlilik & Güvenlik';
  static const String helpAndSupportTitle = 'Yardım & Destek';
  static const String logoutOrSwitchRoleButton = 'Çıkış Yap / Rol Değiştir';
  static const String editAccountModalTitle = 'Hesap Bilgilerini Düzenle';
  static const String accountUpdatedSnack = 'Hesap bilgileri güncellendi.';
  static const List<String> paymentModalItems = <String>[
    'Bu yerel demoda kayıtlı kart veya ödeme işlemi yoktur.',
    'Rezervasyon tutarı yalnız teklif bilgisidir; kartınızdan ücret alınmaz.',
  ];
  static const List<String> privacyModalItems = <String>[
    'Kayıtlarınız bu cihazdaki yerel depoda tutulur; sunucuya gönderilmez.',
    'Hesaplar uygulama içinde ayrılır. Giriş, sunuculu kimlik doğrulama sağlamayan bir demodur.',
    'Seçtiğiniz profil fotoğrafı uygulamanın yerel klasörüne kopyalanır.',
  ];
  static const List<String> helpModalItems = <String>[
    'Bu demoda canlı destek, acil yardım hattı veya hizmet garantisi sunulmaz.',
    'Bekleyen talepleri veya henüz başlamamış onaylı rezervasyonları iptal edebilirsiniz.',
    'Başlamış hizmetler iptal edilemez. Bu demoda ödeme ve iade işlemi yapılmaz.',
  ];

  // Shared Modals (Call, Chat, Live Tracking)
  static const String phoneCallTitle = 'Telefon Araması';
  static const String demoCallDisclaimer =
      'Bu ekran arama demosudur. Telefon araması başlatmaz.';
  static String callingContactSnack(String name, String phone) =>
      'Arama demosu: $name ($phone)';
  static const String callActionButton = 'Demoyu Göster';
  static const String chatOnlineSubtitle = 'Yerel demo konuşması';
  static const String chatInputHint = 'Mesajınızı yazın...';
  static const String liveWalkTrackingTitle = 'Yürüyüş Takip Demosu';
  static const String marmaraSeaLabel = 'Marmara Denizi (Caddebostan Sahil)';
  static const String elapsedTimeLabel = 'Geçen Süre';
  static const String elapsedTimeValue = 'Örnek: 24 dakika';
  static const String walkDistanceLabel = 'Yürüyüş Mesafesi';
  static const String walkDistanceValue = 'Örnek: 1,4 km';
  static const String liveTrackingDemoDisclaimer =
      'Demo modu simüle edilmiş yürüyüş rotasıdır. Canlı GPS bağlantısı gerektirmez.';
}
