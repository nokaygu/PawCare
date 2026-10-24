# PawCare — Geliştirme Yol Haritası ve Uygulama Planı (`plan.md`)

Bu doküman; `docs/project.md`, `docs/architecture.md`, `docs/skills.md` ve `docs/design-system.md` kuralları doğrultusunda, PawCare projesinin mevcut kodunu Stitch tasarımını bozmadan **Feature-First + Saf Hive + Merkezi Tema + Merkezi Metin (`AppStrings`) + SOLID** mimarisine taşımak ve tüm etkileşimlerini eksiksiz tamamlamak için hazırlanmıştır.

> **İlerleme kuralı:** `yapilanlar.md` ve `eksiklikler.md` maddeleri yalnız uygulama ve ilgili doğrulama tamamlandıktan sonra `[x]` yapılır. Önceki tamamlanma beyanları kesinti sonrası yeniden kontrol edilir.

---

## FAZ 1: Bağımlılık Temizliği ve Saf Hive Veri Katmanı (JSON Yok!) — [TAMAMLANDI]

> **Amaç:** Gereksiz paketleri ve JSON bağımlılığını tamamen kaldırmak, tüm veri ve ayarları yalnızca `Hive` üzerinde toplamak, kalıcı fotoğraf servisini ve Repository katmanını kurmak.

### Adım 1.1: `pubspec.yaml` ve `analysis_options.yaml` Yapılandırması
- **Yapılan İş:**
  - `pubspec.yaml` içinde yalnızca `hive`, `hive_flutter`, `image_picker` ve `path_provider` paketleri tutuldu (`shared_preferences`, `table_calendar`, `go_router`, `flutter_bloc` veya JSON varlık tanımları eklenmedi).
  - `analysis_options.yaml` dosyası `docs/skills.md` içindeki en sıkı linter kurallarıyla (`prefer_const_constructors: error`, `deprecated_member_use: error`) güncellendi.
- **Tamamlanma Kontrolü:** `flutter pub get` hatasız tamamlandı.

### Adım 1.2: Modellerin Taşınması ve Hive Serileştirmesi (`toMap` / `fromMap`)
- **Yapılan İş:** `lib/data/models/models.dart` altında tüm modeller (`UserRole`, `Vaccination`, `Dog`, `SitterListing`, `BookingRequest`, `ChatMessage`, `NotificationItem`) `immutable`, `copyWith` ve Hive için tür güvenli `toMap`/`fromMap` dönüşümleriyle yapılandırıldı.
- **Tamamlanma Kontrolü:** Model birim testleri hatasız çalıştı.

### Adım 1.3: Saf Dart Hive Başlangıç Verisi (`hive_seed_data.dart`) ve Fotoğraf Kalıcılığı
- **Yapılan İş:**
  - Başlangıç hizmet veren (`SitterListing`), örnek köpek (`Barley`) ve başlangıç kayıtları `lib/data/local/hive_seed_data.dart` içinde saf Dart nesneleri olarak tanımlandı.
  - `lib/data/local/hive_boxes.dart` içinde `dogs_box`, `sitters_box`, `bookings_box`, `notifications_box` ve `settings_box` kutuları açıldı ve ilk açılışta otomatik tohumlandı (`seed`).
  - `lib/core/utils/image_storage_service.dart` ile `image_picker`'dan seçilen fotoğraflar kalıcı uygulama dizinine kopyalandı.

### Adım 1.4: Repository Katmanının Oluşturulması (SOLID)
- **Yapılan İş:** `DogRepository`, `SitterRepository`, `BookingRepository`, `NotificationRepository` ve `SettingsRepository` sınıfları `lib/data/repositories/` altında oluşturuldu.

---

## FAZ 2: Merkezi Tema Sistemi (Sıfır Satır İçi Renk/FontWeight/Boyut/Metin) ve Splash — [TAMAMLANDI]

### Adım 2.1: `app_colors.dart`, `app_typography.dart`, `app_theme.dart`, `app_dimens.dart` ve `app_strings.dart`
- **Yapılan İş:**
  - `lib/core/theme/app_colors.dart`: Tüm Stitch açık tema ve Koyu Yeşil/Haki (`#16241A`, `#1E3023`, `#243628`, `#344638`, `#DCE5D7`) renk sabitleri tanımlandı.
  - `lib/core/theme/app_typography.dart`: Nunito Sans yazı ailesinin tüm boyut ve `FontWeight` değerleri merkezi `TextTheme` olarak tanımlandı.
  - `lib/core/theme/app_theme.dart`: `lightTheme`, `darkTheme` ve `PawThemeExtension` tanımlandı.
  - `lib/core/constants/app_dimens.dart`: Tüm padding, margin, radius, boyut ve alpha sabitleri merkezi hale getirildi.
  - `lib/core/constants/app_strings.dart`: Tüm ekran ve widget metinleri çoklu dil hazırlığı kapsamında `AppStrings` sınıfında toplandı.
  - `lib/core/theme/theme_controller.dart`: Tercihi `SettingsRepository` üzerinde saklayan reaktif `ThemeController` yazıldı.

### Adım 2.2: Animasyonlu PawCare Splash Ekranı
- **Yapılan İş:** `lib/features/splash/` altında PawCare logosu, ölçülü parlama/ölçek animasyonu ve "PawCare" başlığı içeren splash ekranı oluşturuldu.

---

## FAZ 3: Navigasyon İskeleti ve Ortak DRY Bileşenler (`core/widgets/`) — [TAMAMLANDI]

### Adım 3.1: `AppRouter`, `AppShell` ve `PawBottomNav`
- **Yapılan İş:**
  - `lib/app/router/app_router.dart` ve `app_shell.dart` dosyaları kuruldu; kullanılmayan `route_names.dart` son teknik denetimde kaldırıldı.
  - Geçici yeşil "Ekranlar:" çubuğu tamamen kaldırıldı.
  - Aktif role (`UserRole.owner` / `UserRole.sitter`) göre dinamik değişen 5 sekmeli `PawBottomNav` bileşeni oluşturuldu.

### Adım 3.2: Ortak Başlık (`PawHeaderActions`) ve Saf Flutter Takvim (`PawDateRangeCalendar`)
- **Yapılan İş:**
  - `lib/core/widgets/paw_header_actions.dart` ve `lib/core/widgets/paw_date_range_calendar.dart` harici paket kullanılmadan geliştirildi.

---

## FAZ 4: Ekranların Feature Klasörlerine Taşınması ve SOLID Temizliği — [TAMAMLANDI]

- **Adım 4.1:** `features/onboarding/` ve `features/auth/` (Karşılama ekranı, Giriş ve Kayıt modalları, Rol seçimi).
- **Adım 4.2:** `features/home/` (Köpek Sahibi Ana Sayfası, çoklu köpek hızlı seçimi, canlı rezervasyon nabız göstergesi, dinamik aşı uyarısı, `HomeController`).
- **Adım 4.3:** `features/discovery/` (Keşfet, kategori/fiyat/arama filtreleri, dinamik sonuç sayacı, Hizmet Detay, köpek seçimi ve `PawDateRangeCalendar` ile Hive üzerine rezervasyon kaydetme).
- **Adım 4.4:** `features/pets/` (Çoklu Köpek Profili, `ImageStorageService` ile kalıcı fotoğraf seçimi, Sağlık Kartı modalı, aşı ekleme/durum değiştirme, profil düzenleme ve yeni köpek ekleme modalları).
- **Adım 4.5:** `features/provider/` (Hizmet Veren Paneli, gelen talepleri Onayla/Reddet, İlanım düzenleme, Müsaitlik Takvimi ve Değerlendirmeler sekmeleri).
- **Adım 4.6:** `features/bookings/` ve `core/widgets/modals/` (Taleplerim sekmesi, talep iptali, Sohbet, Canlı Takip Demo Haritası ve Arama Onay modalları).

---

## FAZ 5: Yerel Bildirimler ve Profil / Koyu Yeşil Tema Seçici — [TAMAMLANDI]

- **Adım 5.1:** `features/notifications/` altında 4 yerel demo olayını Hive üzerinden yöneten bildirim penceresi ve sağ üst rozet sayacı tamamlandı.
- **Adım 5.2:** `features/profile/` altında rol duyarlı kullanıcı/köpek özeti (`Aygen Y.` / `Ayşe Yılmaz`), hesap düzenleme, alt bilgi modalları, rol değiştirme, **Açık Tema / Koyu Yeşil (Haki) Tema Seçicisi** ve çıkış aksiyonu tamamlandı.

---

## FAZ 6: Eski Dosyaların Silinmesi ve Nihai Denetim — [TAMAMLANDI]

- **Adım 6.1:** Eski `lib/state/app_state.dart`, `lib/screens/`, `lib/theme/`, `lib/models/`, `lib/widgets/` klasörleri tamamen silindi.
- **Adım 6.2:** Tüm ekranlarda Açık ve Koyu Yeşil (Haki) tema kontrastı, Stitch sadakati ve responsive yerleşim denetlendi.
- **Adım 6.3:** `dart format .`, `flutter analyze` (0 hata, 0 uyarı) ve `flutter test` komutları çalıştırılıp tüm dokümanlar güncellendi.

---

## FAZ 7 & FAZ 8: Fonksiyonel İyileştirmeler, `AppStrings` ve UX Tekrarlarının Temizliği (`eksiklikler.md`) — [TAMAMLANDI]

- **Adım 7.1:** Rol değişiminde Profil (`Aygen Y.` vs `Ayşe Yılmaz`) ve Ana Sayfa karşılama metinlerinin dinamik senkronizasyonu.
- **Adım 7.2:** Köpeklerim ve Ana Sayfa ekranlarında "Profili Düzenle" (`EditDogProfileModal`), "Yeni Köpek Ekle" (`AddDogModal`), QR Dijital Kimlik (`MicrochipIdentityModal`) ve çoklu köpek seçici (`DogSelectorChipsRow`) entegrasyonu.
- **Adım 7.3:** Hizmet Veren panelinde ilan düzenleme (`_EditSitterListingModal`), müşteri değerlendirmeleri listesi (`_ReviewsListSection`), dinamik kazanç/aktif konuk hesaplaması ve `BookingRequest` içinde köpek fotoğrafı (`petPhotoPath`) ile sahip adının (`ownerName`) dinamik gösterimi.
- **Adım 7.4:** Keşfet ekranında gelişmiş bütçe ve sıralama filtre modalı (`_ExploreFilterModal`) ve arama/kategoriye duyarlı dinamik sonuç başlığı (`_ExploreCountBanner`).
- **Adım 7.5:** Profil ekranında hesap düzenleme (`EditUserProfileModal`) ve Ödeme Yöntemleri / Gizlilik & Güvenlik / Yardım & Destek modalları (`ProfileInfoModal`).
- **Adım 7.6:** Alt navigasyon barıyla mükerrer olan bölümlerin (`OwnerSearchAndCategoriesSection` / `Popüler Hizmetler`, `SitterQuickManagementSection` / `Hızlı Yönetim` ve sağ üst bar mükerrer profil ikonu) kaldırılması ve tüm UI metinlerinin `AppStrings` sınıfına taşınması.


## FAZ 9: Kesinti Sonrası Onarım ve 21 Teknik Denetim Maddesi — [3.2 / 3.3 YENİDEN AÇIK]

1. Dört bozuk merkezi Dart dosyasını gerçek satır sonları ve doğru string kaçışlarıyla onar.
2. Yaşam döngüsü, seed/fallback bellek kullanımı, fotoğraf temizliği ve controller önbelleklerini düzelt (`1.1–2.4`).
3. Aktif köpek kimliği, ekran senkronizasyonu, kişi bazlı sohbet, tarih doğrulaması, sayısal sıralama ve dinamik ücret birimlerini tamamla (`3.1–3.6`).
4. Ölü kodu ve işlevsiz parametreleri temizle; kalan kullanıcı metinlerini `AppStrings`'e taşı (`4.1–4.3`).
5. Keşfet boş durumu, tüm onaylı konuklar, rezervasyon tarih satırı ve gerçekçi ana sayfa kartını tamamla (`5.1–5.4`).
6. Birim/widget testleri, gerçek Hive kapat/aç kalıcılığı, görsel önbelleği/disk temizliği, analiz ve biçimlendirmeyi doğrula; tüm proje belgelerini güncelle.

Güncel madde sonuçları [`eksiklikler.md`](../eksiklikler.md), doğrulama sonuçları [`yapilanlar.md`](../yapilanlar.md) içinde tutulur.

**Yeniden doğrulama (25 Ekim 2026):** 19 madde doğrulandı; 3.2 profil/ilan adı senkronizasyonu ve 3.3 farklı sahiplerde sohbet ayrımı kısmi olduğu için yeniden açıldı. Mevcut 40 test başarılı, analiz ve biçimlendirme temiz; eksik iki senaryo mevcut testlerde kapsanmıyor. Kanıt ve kalan işler `eksiklikler.md` bölüm 7 ve `yapilanlar.md` içinde.
