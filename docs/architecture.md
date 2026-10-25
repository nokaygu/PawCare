# PawCare — Feature-First Mimari ve SOLID Kuralları (`architecture.md`)

## 1. Mimari Yaklaşım

Mevcut **Feature-first + katmanlı yapı** korunmaktadır. Her özellik kendi ekran (`view`), durum yönetimi (`controller`) ve alt bileşenlerini (`widgets`) barındırır. UI katmanı veri erişimini doğrudan yapmaz ve içerisinde metin, stil/renk veya boyut sabiti barındırmaz.

Veri akışı:

`View → Controller (ValueNotifier) → Repository → Hive Local Data Source`

- **View:** Yalnızca ekranı oluşturur, temadan aldığı renk/yazı stillerini, `AppDimens` ölçülerini ve `AppStrings` metinlerini uygular, kullanıcı etkileşimlerini Controller'a iletir.
- **Controller:** Ekranın reaktif durumunu (`ValueNotifier`) ve kullanıcı işlemlerini yönetir (`HomeController`, `DiscoveryController`, `PetsController`, `BookingsController`, `ProviderController`, `ProfileController`, `NotificationsController`, `AuthController`, `ChatController`).
- **Repository:** Veriye erişimin arayüzünü ve iş kurallarını yönetir (`DogRepository`, `SitterRepository`, `BookingRepository`, `NotificationRepository`, `ConversationRepository`, `SettingsRepository`, `SitterAccountRepository`, `PetPhotoRecovery`).
- **Hive Local Data Source:** Tüm uygulama verilerini (`dogs_box`, `sitters_box`, `bookings_box`, `notifications_box`, `settings_box`, `conversations_box`, `messages_box`, `history_archive_box`, `quarantine_box`) okur ve yazar. JSON veya SharedPreferences kullanılmaz.

---

## 2. Güncel Klasör Yapısı

```text
lib/
  main.dart
  app/
    app.dart
    bootstrap.dart              # Kalıcı veri yükleme/hata/yeniden dene
    router/
      app_router.dart
      app_shell.dart           # Controller senkronizasyonu ve rol bazlı 5 sekmeli kabuk
  core/
    theme/
      app_colors.dart          # TEK RENK TANIM DOSYASI
      app_typography.dart      # TEK YAZI TİPİ, BOYUT VE KALINLIK (FontWeight) DOSYASI
      app_theme.dart           # Light & Haki Dark ThemeData ve PawThemeExtension
      theme_controller.dart    # Hive settings_box bağlantılı reaktif tema yönetimi
    constants/
      app_dimens.dart          # TEK BOYUT, PADDING, MARGIN, RADIUS VE ALPHA DOSYASI
      app_strings.dart         # TEK METİN VE ÇOKLU DİL (i18n/l10n) SABİTLERİ DOSYASI
    utils/
      image_storage_service.dart
    widgets/                   # Ortak DRY bileşenler (PawBottomNav, PawDateRangeCalendar, PawHeaderActions vb.)
      modals/
        call_modal.dart
        live_tracking_modal.dart
  data/
    local/
      hive_boxes.dart
      hive_seed_data.dart      # Saf Dart başlangıç verileri (JSON yok!)
      hive_identity_migration.dart # Sürümlü kimlik/ilan geçişi
      conversation_migration.dart  # Kayıpsız mesaj gövdesi/arşiv geçişi
      record_validation.dart      # Bozuk satır yalıtımı
      history_maintenance.dart    # Eski okunmuş bildirim arşivi
    repositories/
      dog_repository.dart      # Çoklu köpek, aktif köpek ve aşı yönetimi
      sitter_repository.dart   # Hizmet veren ilan ve müsaitlik yönetimi
      booking_repository.dart  # Teklif/durum, doğrudan kimlik okuma, ortak snapshot
      notification_repository.dart
      conversation_repository.dart # Mesaj başına gövde, 50 kayıtlık sayfa
      pet_photo_recovery.dart      # Kalıcı picker hedefi ve geri yükleme
      sitter_account_repository.dart
      settings_repository.dart # Tema, aktif rol, aktif köpek, sahip ve bakıcı kimlik bilgileri
    models/
      models.dart              # Immutable, copyWith ve toMap/fromMap; ownerId dahil
      conversation_identity.dart # Sahip–bakıcı çiftinden kararlı konuşma anahtarı
  features/
    chat/
      controller/
      view/                    # ChatModal
    onboarding/
      view/
      widgets/
    auth/
      view/
      controller/
      widgets/
    home/
      view/
      controller/
      widgets/
    discovery/
      view/
      controller/
      widgets/
    pets/
      view/
      controller/
      widgets/
        dog_form_modals.dart       # EditDogProfileModal, AddDogModal, MicrochipIdentityModal
        dog_profile_sections.dart  # DogSelectorChipsRow ve profil kartları
        health_card_modal.dart     # Dinamik aşı karnesi ve durum değiştirme
    bookings/
      view/
      controller/
      widgets/
    provider/
      view/
      controller/
      widgets/
    profile/
      view/
      controller/
      widgets/
        profile_modals.dart        # EditUserProfileModal ve ProfileInfoModal
        profile_sections.dart      # Rol duyarlı ProfileUserSummaryCard ve ayarlar
    notifications/
      view/
      controller/
      widgets/
    splash/
      view/
      widgets/
assets/
  images/
docs/
  architecture.md
  design-system.md
  plan.md
  project.md
  skills.md
test/
eksiklikler.md
yapilanlar.md
```

---

## 3. SOLID ve Mimari Kurallar

1. **Tek Sorumluluk (SRP) ve Metod Uzunluğu:** Hiçbir `build` metodu 40 satırı geçemez (kaynak dosyalarında denetlenir). Karmaşık bölümler özel metodlara (`_build...`) veya `widgets/` klasöründeki alt bileşenlere ayrılır.
2. **Sıfır Satır İçi Metin, Stil ve Ölçü:** `features/` veya `core/widgets/` altındaki hiçbir dosyada doğrudan kullanıcı metni, `Color(...)`, `Colors.xxx`, `FontWeight.w...`, `TextStyle(...)` veya sayısal `padding`/`margin`/`radius`/`width`/`height` tanımlanamaz; yalnızca `core/theme/`, `core/constants/app_dimens.dart` ve `core/constants/app_strings.dart` üzerinden gelen sabitler kullanılır.
3. **Tek Veri Kaynağı (`Hive`) ve Reaktif Senkronizasyon:** View katmanı Hive'a doğrudan erişmez. Tüm okuma/yazma işlemleri Repository sınıfları üzerinden yapılır ve `AppShell` içindeki controller dinleyicileri sayesinde bir sekmede yapılan değişiklik (aktif köpek değişimi, yeni köpek ekleme, rol değiştirme, ilan güncelleme, rezervasyon onay/iptal) tüm ekranlara anında yansır.
4. **DRY (Tek İş = Tek Widget & Sıfır Navigasyon Tekrarı):** Tarih seçici takvim, durum rozeti, avatar görüntüleyici ve ortak modallar tek bir kez yazılır. Alt navigasyon barındaki (`PawBottomNav`) sekmeleri yalnızca tekrar eden gereksiz yönlendirme blokları (`Popüler Hizmetler`, `Hızlı Yönetim`, üst bar mükerrer profil ikonu) kaldırılarak her ekran kendi sorumluluğuna odaklanmıştır.


## 4. Kesinti Sonrası Düzeltmeler — 25 Ekim 2026

- `AppStrings`, `AppDimens`, `AppColors` ve `AppTheme` kaynaklarındaki dosya geneline yazılmış kaçışlı satır sonları onarıldı. Kaynak kodunda gerçek satır sonu, metin içinde gerekiyorsa Dart kaçışı kullanılır.
- `HomeController` rezervasyonları ve sahip adını, `PetsController` köpek listesini, `ProviderState` bakıcı adını bellekte tutar. Getter ve `build` çağrıları Hive verisini yeniden ayrıştırmaz; değişikliklerden sonra açık yenileme yapılır.
- İptal, onay, ilan/müsaitlik, profil ve kayıt/rol geçişi değişiklikleri `AppShell._syncAllListingsAndBookings` üzerinden ilgili controller'lara yayılır.
- Sohbet anahtarı `ConversationIdentity.key(ownerId, sitterId)` ile iki kararlı kimlikten üretilir. Okuma/yazma API'si her iki kimliği zorunlu tutar; `senderRole` rol değiştiğinde gönderici ve balon yönünü korur. Eski tek havuzlar güvenli geçişten geçirilir; belirsiz satırlar arşivlenir.
- Dinamik demo listeleri `createInitialSitters()` ve `createInitialBookings()` ile üretilir; test belleği tembel başlatılır ve `clearFallbackMemory()` ile bırakılır.
- Fotoğraf kaydı başarıyla tamamlandıktan sonra başka köpek veya rezervasyon tarafından kullanılmayan eski uygulama fotoğrafı diskten ve iki görsel sağlayıcının önbelleğinden çıkarılır. Galerideki asıl dosya korunur. Görsel okuma asenkrondur; bulunamayan eski fotoğraf için paket içi görsel gösterilir.
- `RouteNames` ve kullanılmayan `SplashController` kaldırıldı. Ortak başlık ve ekranlarda işlevsiz `onProfileTap` zinciri temizlendi.
- Takvim ve rezervasyon controller'ı dolu günleri geçen aralıkları engeller; kayıt öncesi en güncel müsaitlik tekrar okunur.

Denetim maddeleri: [`eksiklikler.md`](../eksiklikler.md). Son doğrulamalar: [`yapilanlar.md`](../yapilanlar.md).

### Tamamlanan kimlik ve profil akışı

`ProfileController` doğru `activeSitterId` ilanını ve ayarlarını kaydeder; sonra `AppShell` controller'ları yeniler. Tarihî rezervasyonların isim snapshot'ları korunur. `AuthController` yerel sahip kimliğini kayıt/girişte etkinleştirir; `AppRouteState.sessionRevision` aynı rol içindeki hesap geçişlerinde de cache yeniler. Home ve Taleplerim `ownerId`, hizmet veren paneli `activeSitterId` üzerinden kayıtları süzer.

`HiveIdentityMigration` eski kayıtların eksik sahip kimliklerini kalıcılaştırır, tek sahibi tanınan eski konuşmaları ilgili çifte taşır ve daha önce yalnız ayarlarda güncellenen bakıcı adını ilan kaydına uygular. Karışık/atanamayan geçmiş `history_archive_box` içindeki `legacy_chat_archive_*` anahtarlarında korunur. Yerel kimlik yönetimi gerçek sunucu doğrulaması değildir. Önceki 61 test bu akışları içerir; yeni kapsam aşağıdadır.

## 5. Hesap sınırları — Yeni denetim Adım 1

`Dog.ownerId` ve sahip bazlı aktif pet anahtarı erişimi sınırlar. `DogRepository` eksik/yabancı kimlikte yazmaz; `findCurrentDog` boş dönebilir, `PetsController` `LifecycleNotifier<Dog?>` taşır. View boş state'i `EmptyPetsCard` ile ele alır; rezervasyon pet seçilmeden gönderilemez. Hesap değişimi pets/bildirim cache'lerini yeniler.

`NotificationItem` alıcı kimliği/rolü, kayıt ilişkisi ve `createdAt` tutar. Repository okuma/okundu işlemini etkin alıcıya sınırlar; yeni olaylar `RecordId` ile üretilir, saat metni görünümde hesaplanır. `SitterAccountRepository` e-postayı kararlı bakıcı/ilan kimliğine eşler; yeni kayıtlar başka ilanı değiştirmeyen taslak üretir. `isPublished` taslağı katalogdan ayırır.

`demo_seeded_v1` ilk tohumlamayı işaretler; sonraki bilinçli boş kutular doldurulmaz. Sahipsiz eski pet/bildirim satırları legacy demo kimliğinde korunur. 71 test ve analiz temiz; bu ilk adım bütün performans/yaşam döngüsü maddelerinin tamamlandığı anlamına gelmez.


## Kalıcı veri, önbellek ve kurtarma sözleşmesi

- AppShell controllerları ihtiyaç anında oluşturur. BookingRepository tek değişmez snapshotı kutu revizyonuyla paylaşır; rezervasyon/ilan/profil yenilemeleri ayrı yapılır. Profil getterları kayıt ayrıştırmaz; öne çıkan ilan sıralaması yalnız katalog değişiminde yenilenir.
- Normal kutular: köpek, ilan, rezervasyon, etkin bildirim, ayar ve konuşma sayaçları. LazyBox: mesaj gövdeleri, uzun arşiv, bozuk kayıt kopyaları. Sohbet ve bildirim arşivi ekranları 50 kayıtlık pencere kullanır; gömülü listeler 20 kayıtlık sayfadır.
- `PawCareBootstrap` Hive açılışı, sürümlü geçişler ve bekleyen fotoğrafı tamamlamadan uygulama controllerlarını oluşturmaz. Hata tekrar denenebilir; kalıcı veri açılışında bellek demosuna geçilmez. Bozuk satırın aslı korunur, okunabilen diğer kayıtlar kullanılabilir.
- Okunmuş ve tarihi bilinen 90 günden eski bildirimler alıcıya ait arşive taşınır; okunmamış/tarihsiz kayıtlar etkin kalır. Sohbet/legacy arşivi otomatik silinmez. Fotoğraf temizliği 24 saatten yeni dosyaları ve tüm hesapların pet/rezervasyon/ilan referanslarını korur.
- Kapanan controller bildirim üretmez. Profil/giriş yazımları hesap kuyruğunda yürür; asıl işlem kaydedilip yalnız ikincil bildirim/temizlik başarısızsa işlem yeniden oluşturulmaz.

<!-- audit-progress:start -->

**Yeni denetim güncel durumu: 47/50 tamamlandı, 3 kabul bekliyor. 171 VM testi başarılı; 3 Chrome senaryosu doğrulandı; Flutter analizi temiz.**

Bekleyen fotoğraf işlemi açılışta ön plana dönüşü bekler; Android URI sonucu 100 ms aralıklarla en fazla 5 saniye sorgulanır. Bootstrap kapanınca yaşam döngüsü dinleyicisi bırakılır. LazyBox ve sınırlı decode native ölçümle doğrulandı.

ImageStorageService webde Android lost-data ve native dizin bakımını kısa devre eder; bootstrap webde Android tekrar sorgusunu açmaz.

Ayrıntılı görev/kabul durumu: [eksiklikler.md](../eksiklikler.md).

<!-- audit-progress:end -->
