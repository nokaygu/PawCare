# PawCare — Feature-First Mimari ve SOLID Kuralları (`architecture.md`)

## 1. Mimari Yaklaşım

Mevcut **Feature-first + katmanlı yapı** korunmaktadır. Her özellik kendi ekran (`view`), durum yönetimi (`controller`) ve alt bileşenlerini (`widgets`) barındırır. UI katmanı veri erişimini doğrudan yapmaz ve içerisinde metin, stil/renk veya boyut sabiti barındırmaz.

Veri akışı:

`View → Controller (ValueNotifier) → Repository → Hive Local Data Source`

- **View:** Yalnızca ekranı oluşturur, temadan aldığı renk/yazı stillerini, `AppDimens` ölçülerini ve `AppStrings` metinlerini uygular, kullanıcı etkileşimlerini Controller'a iletir.
- **Controller:** Ekranın reaktif durumunu (`ValueNotifier`) ve kullanıcı işlemlerini yönetir (`HomeController`, `DiscoveryController`, `PetsController`, `BookingsController`, `ProviderController`, `ProfileController`, `NotificationsController`, `AuthController`).
- **Repository:** Veriye erişimin arayüzünü ve iş kurallarını yönetir (`DogRepository`, `SitterRepository`, `BookingRepository`, `NotificationRepository`, `SettingsRepository`).
- **Hive Local Data Source:** Tüm uygulama verilerini (`dogs_box`, `sitters_box`, `bookings_box`, `notifications_box`, `settings_box`) okur ve yazar. JSON veya SharedPreferences kullanılmaz.

---

## 2. Güncel Klasör Yapısı

```text
lib/
  main.dart
  app/
    app.dart
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
        chat_modal.dart
        live_tracking_modal.dart
  data/
    local/
      hive_boxes.dart
      hive_seed_data.dart      # Saf Dart başlangıç verileri (JSON yok!)
    repositories/
      dog_repository.dart      # Çoklu köpek, aktif köpek ve aşı yönetimi
      sitter_repository.dart   # Hizmet veren ilan ve müsaitlik yönetimi
      booking_repository.dart  # Rezervasyon oluşturma, durum güncelleme, iptal ve mesajlaşma
      notification_repository.dart
      settings_repository.dart # Tema, aktif rol, aktif köpek, sahip ve bakıcı kimlik bilgileri
    models/
      models.dart              # Immutable, copyWith ve toMap/fromMap destekli modeller (petPhotoPath, ownerName dahil)
  features/
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
- Sohbet anahtarı görünen isim yerine değişmeyen `sitterId` değeridir: `chat_messages_<sitterId>`. Mesajdaki `senderRole`, rol değiştiğinde gönderici ve balon yönünü korur. Eski tek havuzdaki demo geçmişi yalnız ilgili gezdirici konuşmasına taşınır.
- Dinamik demo listeleri `createInitialSitters()` ve `createInitialBookings()` ile üretilir; test belleği tembel başlatılır ve `clearFallbackMemory()` ile bırakılır.
- Fotoğraf kaydı başarıyla tamamlandıktan sonra başka köpek veya rezervasyon tarafından kullanılmayan eski uygulama fotoğrafı diskten ve iki görsel sağlayıcının önbelleğinden çıkarılır. Galerideki asıl dosya korunur. Görsel okuma asenkrondur; bulunamayan eski fotoğraf için paket içi görsel gösterilir.
- `RouteNames` ve kullanılmayan `SplashController` kaldırıldı. Ortak başlık ve ekranlarda işlevsiz `onProfileTap` zinciri temizlendi.
- Takvim ve rezervasyon controller'ı dolu günleri geçen aralıkları engeller; kayıt öncesi en güncel müsaitlik tekrar okunur.

Denetim maddeleri: [`eksiklikler.md`](../eksiklikler.md). Son doğrulamalar: [`yapilanlar.md`](../yapilanlar.md).


### Yeniden denetimde doğrulanan sınırlar

Profil callback'i controller'ları yeniliyor; bakıcı adı yalnız ayarlarda değiştiği için SitterListing.name alanı ve ilan kartları güncellenmiyor (3.2 açık). Sohbetin mevcut `sitterId` anahtarı bakıcıları ayırıyor, aynı bakıcıya bağlı farklı sahipleri ayırmıyor (3.3 açık). Önceki senkronizasyon/kişi bazlı ayrım açıklamaları bu sınırlarla okunmalıdır; ayrıntılı kanıt `eksiklikler.md` bölüm 7 içindedir.
