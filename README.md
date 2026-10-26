# PawCare — Evcil Hayvan Bakım, Konaklama ve Sağlık Ekosistemi

**PawCare**, köpek sahiplerini güvenilir köpek otelleri, ev ortamında bakım verenler, gezdiriciler, kreşler ve veterinerlerle buluşturan; aynı zamanda çoklu köpek profillerini, dijital mikroçip kimliğini, sağlık ve aşı karnelerini ve rezervasyon süreçlerini tek bir çatı altında yöneten çevrimdışı öncelikli (*Offline-First*) bir Flutter yerel demo uygulamasıdır.

---

## Temel Özellikler

- **Tam Senkronize Çift Rol Deneyimi (Köpek Sahibi & Hizmet Veren / Bakıcı):**
  - **Köpek Sahibi Modu:** Çoklu köpek hızlı geçişli özet paneli, sağlık kartı ve doğrudan profil düzenleme modalları, gelişmiş hizmet keşfi (dinamik sonuç başlığı, kategori, arama, maksimum bütçe ve fiyat sıralaması), tarih aralığı ve köpek seçimiyle rezervasyon talebi oluşturma, bekleyen talepleri iptal etme veya bakıcıyla mesajlaşma.
  - **Hizmet Veren Modu:** Gelen rezervasyon taleplerini (köpeğin gerçek fotoğrafı ve sahip adıyla) onaylama/reddetme, bu ay başlayan onaylı rezervasyonların brüt toplamı, konuk takibi ve hizmet tamamlama, ilan başlığı/fiyatı/açıklaması düzenleme, kapasite/müsaitlik takvimi yönetimi ve açıkça örnek olarak etiketlenen değerlendirmeler.
  - **Rol Bazlı Dinamik Profil:** Aktif rol değiştirildiğinde Profil ekranındaki kullanıcı adı, e-posta, ilgili ilanın avatarı veya genel kişi rozeti ve alt özet bilgileri anında ilgili role uyum sağlar.
- **Merkezi Metin ve Çoklu Dil Altyapısı (`AppStrings`):**
  - Tüm ekranlar ve ortak bileşenlerdeki statik/parametreli kullanıcı arayüzü metinleri `lib/core/constants/app_strings.dart` (`AppStrings`) altında toplanmıştır; widget'ların içinde doğrudan gömülü metin sabiti (`hardcoded string`) bulunmaz ve uygulama çoklu dil (`i18n` / `l10n`) geçişine hazırdır.
- **Çoklu Köpek Yönetimi, Sağlık Kartı ve Dijital Kimlik:**
  - **Profili Düzenle & Yeni Köpek Ekle (`dog_form_modals.dart`):** Hem Ana Sayfa hem Köpeklerim sekmesinden mevcut köpeğin tüm bilgilerini düzenleme veya yeni köpek ekleyip köpekler arasında (`DogSelectorChipsRow`) tek dokunuşla geçiş yapma.
  - **Dinamik Aşı Karnesi & Mikroçip Kimliği:** Yeni aşı ekleme, mevcut aşıların durumunu (`Tamamlandı` / `Yaklaşıyor` / `Gecikti`) tek dokunuşla güncelleme, yaklaşan aşı uyarılarını otomatik görüntüleme ve Metin Mikroçip Kimliği (`MicrochipIdentityModal`) kartı.
- **Saf Hive Yerel Veri Katmanı (Sıfır JSON, Sıfır Legacy & Sıfır Migrasyon):**
  - Başlangıç verileri (`lib/data/local/hive_seed_data.dart`) doğrudan saf Dart nesneleri olarak `Hive` kutularına (`dogs_box`, `sitters_box`, `bookings_box`, `notifications_box`, `settings_box`) yalnız ilk demo kurulumunda tohumlanır. Ayrı konuşma metadatası, mesaj, arşiv ve karantina kutuları kullanılır; mesaj/arşiv/karantina gövdeleri LazyBox içinde tutulur.
  - **Sıfır Legacy / Sıfır Migrasyon Politikası:** Projede hiçbir şekilde geriye dönük uyumluluk veya ara geçiş için geçici `migration` sınıfları, `legacy` kimlik alanları (`owner_legacy`, `legacyOwnerId`) veya eski şema dönüştürücüler bulunmaz ve eklenemez. Tüm veri akışı doğrudan saf, tip güvenli güncel modeller (`lib/data/models/models.dart`) ile yürütülür.
- **Kalıcı Yerel Fotoğraf Yönetimi:**
  - `image_picker` ve `path_provider` ile galeriden seçilen köpek fotoğrafları uygulama belgeler dizinine en fazla 1.600 piksel kenarla kaydedilir. Küçük görseller hedef boyutta çözülür; bekleyen galeri seçiminin hesap/köpek hedefi süreç yeniden açılışında korunur.
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
│   ├── bootstrap.dart
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
│           └── live_tracking_modal.dart
├── data/
│   ├── local/
│   │   ├── history_maintenance.dart
│   │   ├── hive_boxes.dart
│   │   ├── hive_seed_data.dart
│   │   └── record_validation.dart
│   ├── models/
│   │   └── models.dart
│   └── repositories/
│       ├── booking_repository.dart
│       ├── dog_repository.dart
│       ├── notification_repository.dart
│       ├── conversation_repository.dart
│       ├── pet_photo_recovery.dart
│       ├── sitter_account_repository.dart
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
    ├── chat/                    # ChatController ve ChatModal
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

Merkezi Dart dosyalarındaki kaçışlı satır sonları onarıldı. Rezervasyon callback senkronizasyonu, sahip–bakıcı çiftine göre ayrılmış sohbet geçmişi, rol duyarlı gönderici bilgisi, dolu günleri kapsayan tarih aralıkları, sayısal kayıt sıralaması ve dinamik ücret birimleri düzeltildi. Controller verileri ve temalar önbelleğe alınır; görseller asenkron okunur, değiştirilen uygulama fotoğrafları diskten ve görsel önbelleğinden temizlenir.

Keşfet filtre sıfırlama kartı, tüm onaylı konukların listesi, rezervasyon tarih satırı ve aktif kayıt yokken hizmet keşfetme kartı eklendi. Gereksiz nabız animasyonu ve klavye modallarındaki tam ekran blur kaldırıldı. Yeni regresyon testleri sohbet yaşam döngüsü, takvim, Hive kalıcılığı, fotoğraf temizliği, controller önbelleği ve ekran senkronizasyonunu kapsar.

21 maddelik denetim: [`eksiklikler.md`](eksiklikler.md). Son doğrulama sonuçları ve ilerleme: [`yapilanlar.md`](yapilanlar.md).

**Önceki denetim sonucu:** 21/21 madde tamamlandı. Profil adı Home/Keşfet/panelde eşitlenir; sohbetler kararlı sahip–bakıcı çiftiyle ayrılır ve hesap değişiminde ilgili kayıtlar yenilenir. `flutter analyze --no-pub` temiz, `flutter test --no-pub` **61 test başarılı**, Dart biçimlendirmesi temiz. Eski belirsiz sohbet kayıtları silinmeden arşivlenir. Bu sonuç önceki 21 maddelik denetimin kapsamıdır; yeni liste ve ilerleme `eksiklikler.md` ile `yapilanlar.md` içindedir.

## Yeni denetim uygulaması — 25 Ekim 2026

50 maddelik yeni denetimde **47 tamamlandı, 3 açık**; **171 test başarılı**, analiz temiz. İlk adımda hesap bazlı köpek/aktif seçim ve bildirim ayrımı, ayrı bakıcı kimliği/ilan taslağı ve doğru role yeniden giriş uygulandı. Bilinçli boş veri tekrar tohumlanmaz; bildirim zamanı gerçek olay tarihinden üretilir. Yeni sahip köpek ekleme kartıyla başlar. Sunuculu kimlik doğrulama veya ödeme entegrasyonu eklenmedi. Güncel görev ve kabul ölçütleri [eksiklikler.md](eksiklikler.md), kanıtlar [yapilanlar.md](yapilanlar.md) içindedir.


<!-- audit-progress:start -->

**Yeni denetim güncel durumu: 47/50 tamamlandı, 3 kabul bekliyor. 171 VM testi başarılı; 3 Chrome senaryosu doğrulandı; Flutter analizi temiz.**

Android süreç kaybı kabulü tamamlandı; API 35 native profile ile liste, fotoğraf belleği ve depolama ölçüldü. Yalnız iOS cihazı (F01), macOS sandbox (F03) ve gerçek yayın sertifikası (F04) kabulü açık.

Chrome açılışında Android kurtarması ve yerel fotoğraf dosyası taraması atlanır; IndexedDB kayıtları korunur.

Ayrıntılı görev/kabul durumu: [eksiklikler.md](eksiklikler.md).

<!-- audit-progress:end -->


## Cihaz ve yayın doğrulaması

Android debug APK: `build/app/outputs/flutter-apk/app-debug.apk`. Gerçek yayın için `android/key.properties.example` örneğini kullanarak depoya alınmayan `android/key.properties` dosyasını veya `PAWCARE_RELEASE_STORE_FILE`, `PAWCARE_RELEASE_STORE_PASSWORD`, `PAWCARE_RELEASE_KEY_ALIAS`, `PAWCARE_RELEASE_KEY_PASSWORD` ortam değişkenlerini yapılandırın. `storeFile`, Android dizinine göre veya mutlak dosya yoludur. Anahtar/şifre yokken release açık hatayla durur; debug anahtarıyla yayın paketi üretilmez.

iOS galeri açıklaması ve macOS seçilmiş dosya okuma entitlementları eklendi. Apple cihazı/sandbox, Android süreç öldürme, cihaz performans profili ve gerçek sertifikayla yayın paketi kabulleri [eksiklikler.md](eksiklikler.md) içinde açık tutulur. Android emülatör denemelerinde renderer ve ADB yetkilendirme engelleri oluştu; bu girişimler başarılı native test olarak sayılmadı.


## Chrome başlangıcı

`flutter clean` ve `flutter pub get --offline` çalıştırıldı; paket sürümleri değiştirilmedi. Temizlik build/araç çıktılarını yeniler, tarayıcıdaki Hive IndexedDB kayıtlarını silmez. Chrome açılışında webde desteklenmeyen `Platform.isAndroid` çağrısı ve native fotoğraf dizini bakımı engellendi. Mevcut kayıtları sıfırlamadan tekrar `flutter run -d chrome` çalıştırılabilir.
