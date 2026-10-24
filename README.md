# PawCare — Evcil Hayvan Bakım, Konaklama ve Sağlık Ekosistemi

**PawCare**, köpek sahiplerini güvenilir köpek otelleri, ev ortamında bakım verenler, gezdiriciler, kreşler ve veterinerlerle buluşturan; aynı zamanda çoklu köpek profillerini, dijital mikroçip kimliğini, sağlık ve aşı karnelerini ve rezervasyon süreçlerini tek bir çatı altında yöneten çevrimdışı öncelikli (*Offline-First*) bir Flutter mobil uygulamasıdır.

---

## Temel Özellikler

- **Tam Senkronize Çift Rol Deneyimi (Köpek Sahibi & Hizmet Veren / Bakıcı):**
  - **Köpek Sahibi Modu (`Aygen Y.`):** Çoklu köpek hızlı geçişli özet paneli, sağlık kartı ve doğrudan profil düzenleme modalları, gelişmiş hizmet keşfi (dinamik sonuç başlığı, kategori, arama, maksimum bütçe ve fiyat sıralaması), tarih aralığı ve köpek seçimiyle rezervasyon talebi oluşturma, bekleyen talepleri iptal etme veya bakıcıyla mesajlaşma.
  - **Hizmet Veren Modu (`Ayşe Yılmaz — Mutlu Patiler Köpek Oteli`):** Gelen rezervasyon taleplerini (köpeğin gerçek fotoğrafı ve sahip adıyla) onaylama/reddetme, onaylanan rezervasyonlara göre dinamik aylık kazanç ve aktif konuk takibi, ilan başlığı/fiyatı/açıklaması düzenleme, müsaitlik takvimi yönetimi ve müşteri değerlendirmeleri.
  - **Rol Bazlı Dinamik Profil:** Aktif rol değiştirildiğinde Profil ekranındaki kullanıcı adı, e-posta, avatar (`assets/images/ayse.jpg` / sahip rozeti) ve alt özet bilgileri anında ilgili role uyum sağlar.
- **Merkezi Metin ve Çoklu Dil Altyapısı (`AppStrings`):**
  - Tüm ekranlar ve ortak bileşenlerdeki statik/parametreli kullanıcı arayüzü metinleri `lib/core/constants/app_strings.dart` (`AppStrings`) altında toplanmıştır; widget'ların içinde doğrudan gömülü metin sabiti (`hardcoded string`) bulunmaz ve uygulama çoklu dil (`i18n` / `l10n`) geçişine hazırdır.
- **Çoklu Köpek Yönetimi, Sağlık Kartı ve Dijital Kimlik:**
  - **Profili Düzenle & Yeni Köpek Ekle (`dog_form_modals.dart`):** Hem Ana Sayfa hem Köpeklerim sekmesinden mevcut köpeğin tüm bilgilerini düzenleme veya yeni köpek ekleyip köpekler arasında (`DogSelectorChipsRow`) tek dokunuşla geçiş yapma.
  - **Dinamik Aşı Karnesi & Mikroçip Kimliği:** Yeni aşı ekleme, mevcut aşıların durumunu (`Tamamlandı` / `Yaklaşıyor`) tek dokunuşla güncelleme, yaklaşan aşı uyarılarını otomatik görüntüleme ve QR Dijital Kimlik (`MicrochipIdentityModal`) kartı.
- **Saf Hive Yerel Veri Katmanı (Sıfır JSON & Sıfır Harici Backend):**
  - Başlangıç verileri (`lib/data/local/hive_seed_data.dart`) doğrudan saf Dart nesneleri olarak `Hive` kutularına (`dogs_box`, `sitters_box`, `bookings_box`, `notifications_box`, `settings_box`) tohumlanır ve tüm CRUD işlemleri anında kalıcı hale getirilir.
- **Kalıcı Yerel Fotoğraf Yönetimi:**
  - `image_picker` ve `path_provider` ile galeriden veya kameradan seçilen köpek fotoğrafları uygulama belgeler dizinine kopyalanır ve yolu Hive üzerinde saklanır.
- **Merkezi Tasarım Sistemi ("Warm Companion" & Koyu Yeşil / Haki Tema):**
  - Tüm renkler (`AppColors`), tipografi (`AppTypography`), tema uzantıları (`PawThemeExtension`), boyut/boşluk sabitleri (`AppDimens`) ve metinler (`AppStrings`) merkezi olarak yönetilir.
  - Açık Tema (*Warm Alabaster & Forest Green*) ve Koyu Yeşil / Haki Tema (*Deep Khaki `#16241A` & Warm Cream*) arasında anlık ve kalıcı geçiş yapılabilir.
- **Modüler Mimari & SOLID İlkeleri:**
  - Her özellik kendi `features/<modül>/` klasörü altında ekran (`view`), durum yönetimi (`controller`) ve alt bileşenlerine (`widgets`) ayrılmıştır.
  - Dart kaynaklarında `build` metodları en fazla 40 satır sınırına uyacak şekilde atomik widget'lara bölünmüştür ve ekran/widget dosyalarında sıfır satır içi sabit (`text`, `Color`, `FontWeight`, `fontSize`, sayısal `padding`/`radius`/`width`/`height`) bulunmaktadır.

---

## Proje Klasör Yapısı

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── router/
│       ├── app_router.dart
│       └── app_shell.dart
├── core/
│   ├── constants/
│   │   ├── app_dimens.dart
│   │   └── app_strings.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_theme.dart
│   │   ├── app_typography.dart
│   │   └── theme_controller.dart
│   ├── utils/
│   │   └── image_storage_service.dart
│   └── widgets/
│       ├── paw_avatar_image.dart
│       ├── paw_bottom_nav.dart
│       ├── paw_date_range_calendar.dart
│       ├── paw_header_actions.dart
│       ├── paw_status_badge.dart
│       └── modals/
│           ├── call_modal.dart
│           ├── chat_modal.dart
│           └── live_tracking_modal.dart
├── data/
│   ├── local/
│   │   ├── hive_boxes.dart
│   │   └── hive_seed_data.dart
│   ├── models/
│   │   └── models.dart
│   └── repositories/
│       ├── booking_repository.dart
│       ├── dog_repository.dart
│       ├── notification_repository.dart
│       ├── settings_repository.dart
│       └── sitter_repository.dart
└── features/
    ├── splash/
    ├── onboarding/
    ├── auth/
    ├── home/
    ├── discovery/
    ├── pets/
    │   ├── controller/pets_controller.dart
    │   ├── view/dog_profile_screen.dart
    │   └── widgets/
    │       ├── dog_form_modals.dart
    │       ├── dog_profile_sections.dart
    │       └── health_card_modal.dart
    ├── bookings/
    ├── provider/
    ├── notifications/
    └── profile/
        ├── controller/profile_controller.dart
        ├── view/profile_screen.dart
        └── widgets/
            ├── profile_modals.dart
            └── profile_sections.dart
```

---

## Kurulum, Denetim ve Çalıştırma

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```


## Kesinti Sonrası Teknik Onarım — 25 Ekim 2026

Merkezi Dart dosyalarındaki kaçışlı satır sonları onarıldı. Rezervasyon callback senkronizasyonu, bakıcı bazlı sohbet geçmişi, rol duyarlı gönderici bilgisi, dolu günleri kapsayan tarih aralıkları, sayısal kayıt sıralaması ve dinamik ücret birimleri düzeltildi. Controller verileri ve temalar önbelleğe alınır; görseller asenkron okunur, değiştirilen uygulama fotoğrafları diskten ve görsel önbelleğinden temizlenir.

Keşfet filtre sıfırlama kartı, tüm onaylı konukların listesi, rezervasyon tarih satırı ve aktif kayıt yokken hizmet keşfetme kartı eklendi. Gereksiz nabız animasyonu ve klavye modallarındaki tam ekran blur kaldırıldı. Yeni regresyon testleri sohbet yaşam döngüsü, takvim, Hive kalıcılığı, fotoğraf temizliği, controller önbelleği ve ekran senkronizasyonunu kapsar.

21 maddelik denetim: [`eksiklikler.md`](eksiklikler.md). Son doğrulama sonuçları ve ilerleme: [`yapilanlar.md`](yapilanlar.md).

**Son yeniden denetim:** 19 madde doğrulandı; 3.2 (profil adının ilanlara yansıması) ve 3.3 (bakıcı tarafında farklı sahiplerin sohbet ayrımı) kısmi olduğu için yeniden açıldı. `flutter analyze --no-pub` temiz, mevcut 40 test başarılı, Dart biçimlendirme kontrolü temiz; mevcut testler bu iki açığı kapsamıyor. Ayrıntılar `eksiklikler.md` bölüm 7 içinde.
