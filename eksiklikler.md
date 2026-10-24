# PawCare — Kapsamlı Teknik Denetim, Performans, Bellek (RAM) ve UI İyileştirme Raporu (`eksiklikler.md`)

Bu doküman; projenin tüm kaynak kodları (`lib/`), bağımlılıkları (`pubspec.yaml`), bellek/yaşam döngüsü yönetimi, performans darboğazları, mantıksal hataları ve yüksek fayda sağlayacak UI ihtiyaçları incelenerek hazırlanmıştır.


> **25 Ekim 2026 — Yeniden denetim:** Önceki tam tamamlanma beyanı geri çekildi. 3.2 profil adının ilanlara yansıması açısından kısmi; 3.3 bakıcılar arasında ayrımı sağlıyor ancak bakıcı tarafında farklı sahipleri ayırmıyor. Bu iki madde genel gereksinim karşılanana kadar açık tutulur. Diğer 19 maddenin istenen çözüm adımları kaynak ve testlerle doğrulandı. Merkezi Dart dosyalarının kaçış/satır sonu onarımları geçerli.


---

## 1. Bellek Yönetimi (RAM), Global Scope / Singleton ve Memory Leak Bulguları

- [x] **1.1. `ChatModal._sendMessage` İçindeki `Future.delayed` Kaynaklı Lifecycle / Memory Leak Riski ([`chat_modal.dart`](lib/core/widgets/modals/chat_modal.dart)):**
  - **Sorun:** Mesaj gönderildikten sonra kullanılan `Future<void>.delayed(const Duration(milliseconds: 100), () { ... })` bloğunda `if (!mounted) return;` kontrolü bulunmuyor. Kullanıcı mesaj gönderip 100ms içinde pencereyi kapatırsa `dispose()` edilmiş `_scrollController` tetiklenmeye çalışılıyor.
  - **Çözüm:** `Future.delayed` kaldırılarak `WidgetsBinding.instance.addPostFrameCallback` kullanılmalı ve `mounted` kontrolü eklenmeli.

- [x] **1.2. `OwnerHomeScreen` İçinde Durmaksızın Çalışan Sonsuz `AnimationController` ([`owner_home_screen.dart`](lib/features/home/view/owner_home_screen.dart)):**
  - **Sorun:** `_pulseController` ekran açık olduğu sürece (aktif onaylı bir rezervasyon olmasa dahi) 60 FPS'de sürekli `repeat(reverse: true)` ile çalışıyor ve GPU/CPU tüketiyor.
  - **Çözüm:** Animasyon yalnızca gerçekten aktif (`confirmed`) bir rezervasyon varken çalıştırılmalı veya sadece rozet widget'ı kendi yaşam döngüsünde gerektiğinde animasyonu başlatmalı.

- [x] **1.3. `HiveBoxes._fallbackMemory` ve `HiveSeedData` Statik Nesnelerinin RAM'de Sürekli Tutulması ([`hive_boxes.dart`](lib/data/local/hive_boxes.dart), [`hive_seed_data.dart`](lib/data/local/hive_seed_data.dart)):**
  - **Sorun:** `HiveSeedData.initialSitters` ve `HiveSeedData.initialBookings` `static final` olarak tanımlandığı için ilk tohumlama (seed) bittikten sonra bile uygulama kapanana kadar global bellekte (RAM) tutulmaya devam ediyor. Ayrıca `HiveBoxes._fallbackMemory` sadece Hive kutusu kapalıysa (test ortamında) kullanılmasına rağmen her zaman bellekte statik `Map` olarak bekliyor ve temizleme (`clear`) metodu bulunmuyor.
  - **Çözüm:** `HiveSeedData` içindeki sabit olmayan listeler `static final` yerine yalnızca seed anında çağrılan fabrika metodlarına (`createInitialSitters()`, `createInitialBookings()`) dönüştürülmeli; böylece seed işlemi bittikten sonra Garbage Collector (GC) tarafından RAM'den temizlenebilmeli.

- [x] **1.4. Değiştirilen Köpek Fotoğraflarının Diskte ve `ImageCache`'te Yetim Kalması ([`image_storage_service.dart`](lib/core/utils/image_storage_service.dart), [`pets_controller.dart`](lib/features/pets/controller/pets_controller.dart)):**
  - **Sorun:** Kullanıcı her fotoğraf güncellediğinde `pawcare_pets/pet_<timestamp>.jpg` olarak yeni bir dosya kopyalanıyor fakat önceki yerel fotoğraf dosyası silinmiyor ve Flutter `imageCache` üzerinden `FileImage` tahliyesi (`evict`) yapılmıyor.
  - **Çözüm:** Yeni fotoğraf kaydedildiğinde, eğer eski fotoğraf `assets/` dışındaki bir yerel dosya ise diskten silinmeli ve `FileImage(oldFile).evict()` ile RAM önbelleğinden düşürülmeli.

---

## 2. Performans Darboğazları (CPU, Disk I/O ve Gereksiz Rebuild Sorunları)

- [x] **2.1. Her UI Çiziminde (`build`) Hive Kutularının Baştan Deserialize Edilmesi ([`home_controller.dart`](lib/features/home/controller/home_controller.dart), [`pets_controller.dart`](lib/features/pets/controller/pets_controller.dart), [`provider_controller.dart`](lib/features/provider/controller/provider_controller.dart)):**
  - **Sorun:**
    - `HomeController.activeConfirmedBooking` getter'ı her çağrıldığında tüm `bookings_box` verisini Hive'dan çekip `fromMap` ile nesneye çeviriyor ve sıralıyor.
    - `PetsController.allDogs` getter'ı her `build` sırasında tüm köpekleri ve aşı listelerini Hive'dan yeniden parse ediyor.
    - `ProviderState.sitterDisplayName` her çizimde `SettingsRepository().getSitterName()` ile Hive okuma işlemi yapıyor.
  - **Çözüm:** Controller'lar kendi durum nesnelerinde (`state`) önbelleğe alınmış (cached) listeleri tutmalı; yalnızca veri değiştiğinde (`refresh` / `save`) Hive'dan okuma yapılmalı.

- [x] **2.2. `build()` Metodu İçinde Ana Thread'de Senkron Disk I/O (`file.existsSync()`) Yapılması ([`paw_avatar_image.dart`](lib/core/widgets/paw_avatar_image.dart)):**
  - **Sorun:** `PawImageProvider.resolve` ve `PawBoxImage.build` her çalıştığında UI thread üzerinde `File(path).existsSync()` çağırıyor. Liste kaydırırken senkron dosya sistemi sorgusu yapmak frame düşmelerine (UI jank) yol açar.
  - **Çözüm:** `PawBoxImage` içinde `existsSync()` yerine `Image.file(..., errorBuilder: ...)` kullanılmalı; `PawImageProvider` için ise hafif bir bellek içi geçerlilik kontrolü veya `errorBuilder` destekli yapı tercih edilmeli.

- [x] **2.3. `AppTheme.lightTheme` ve `AppTheme.darkTheme` Getter'larının Her Seferinde Sıfırdan `ThemeData` Üretmesi ([`app_theme.dart`](lib/core/theme/app_theme.dart)):**
  - **Sorun:** `lightTheme` ve `darkTheme` `static final` alan yerine getter olarak tanımlandığı için `PawCareApp` her yeniden çizildiğinde tüm `ThemeData` ve `TextTheme` nesneleri bellekte baştan yaratılıyor.
  - **Çözüm:** `static final ThemeData lightTheme = _buildLightTheme();` ve `static final ThemeData darkTheme = _buildDarkTheme();` olarak bellekte tek bir kez oluşturulmalı.

- [x] **2.4. Klavye Açılan Modallarda Tam Ekran `BackdropFilter` Blur Maliyeti ([`chat_modal.dart`](lib/core/widgets/modals/chat_modal.dart), [`login_modal.dart`](lib/features/auth/view/login_modal.dart), [`signup_modal.dart`](lib/features/auth/view/signup_modal.dart)):**
  - **Sorun:** İçinde `TextField` bulunan diyaloglarda klavye açılıp kapanırken (`MediaQuery.viewInsets` değişirken) arka plandaki `BackdropFilter(filter: ImageFilter.blur(...))` her karede yeniden hesaplanarak mobil cihazlarda takılmalara yol açar.
  - **Çözüm:** `BackdropFilter` kaldırılarak veya sabit katmana alınarak yarı saydam `modalBarrier` rengi ile akıcı 60/120 FPS pencere geçişi sağlanmalı.

---

## 3. Mantıksal Hatalar ve Veri Tutarsızlıkları (Bugs)

- [x] **3.1. `SettingsRepository.getActiveDogId()` Varsayılan ID Uyuşmazlığı (`'dog_barley'` vs `'dog_1'`) ([`settings_repository.dart`](lib/data/repositories/settings_repository.dart)):**
  - **Sorun:** Tohumlanan ilk köpeğin ID'si `'dog_1'` ([`hive_seed_data.dart`](lib/data/local/hive_seed_data.dart)) iken `SettingsRepository.getActiveDogId()` varsayılan olarak `'dog_barley'` döndürüyor.
  - **Çözüm:** Varsayılan değer `HiveSeedData.initialDog.id` (`'dog_1'`) ile eşitlenmeli.

- [ ] **3.2. Rezervasyon İptalinin Ana Sayfaya Yansımaması ve Statü Karmaşası ([`app_shell.dart`](lib/app/router/app_shell.dart), [`bookings_controller.dart`](lib/features/bookings/controller/bookings_controller.dart)):**
  - **Sorun:** `AppShell` içinde `BookingsController.onBookingsChanged` yalnızca `_providerController.refresh()` metodunu çağırıyor (`_syncAllListingsAndBookings` çağrılmıyor). Ayrıca profilde kullanıcı adı veya bakıcı adı güncellendiğinde (`ProfileController.updateActiveUserProfile`) `HomeController` ve `ProviderController` bilgilendirilmediği için diğer sekmelerde eski isim kalabiliyor.
  - **Çözüm:** `BookingsController` ve `ProfileController` güncellemeleri `AppShell` üzerinden ilgili tüm controller'ları (`_homeController`, `_providerController`, `_bookingsController`) senkronize etmeli.

- [ ] **3.3. Sohbet Mesajlarının Tüm Bakıcılar İçin Tek Bir Havuzda Karışması ([`chat_modal.dart`](lib/core/widgets/modals/chat_modal.dart), [`settings_repository.dart`](lib/data/repositories/settings_repository.dart)):**
  - **Sorun:** `SettingsRepository.getChatMessages()` tüm mesajları tek bir `'chat_messages'` anahtarında tutuyor. Kullanıcı **Ayşe Yılmaz** ile sohbet açtığında da **Mert Demir**'in yürüyüş mesajlarını görüyor. Ayrıca Bakıcı modunda sohbet açıldığında da gönderici adı her zaman sahip adı (`getOwnerName()`) olarak kaydediliyor.
  - **Çözüm:** Sohbet geçmişi muhatap bazlı anahtarlarla (`chat_messages_<contactKey>`) ayrıştırılmalı ve aktif role göre mesaj gönderici adı doğru atanmalı.

- [x] **3.4. Tarih Seçiminde (`PawDateRangeCalendar`) Arada Kalan Dolu Günlerin Atlanabilmesi ([`paw_date_range_calendar.dart`](lib/core/widgets/paw_date_range_calendar.dart)):**
  - **Sorun:** Bakıcının dolu olduğu günlere (ör. 29-30 Ekim) doğrudan tıklanamıyor fakat başlangıç `28 Ekim`, bitiş `31 Ekim` seçildiğinde aradaki dolu günleri kapsayan rezervasyon aralığına izin veriliyor.
  - **Çözüm:** Seçilen `start` ve `end` tarihleri arasında `unavailableDates` içinde yer alan herhangi bir gün varsa aralık seçimi engellenmeli ve yalnızca geçerli aralıklar kabul edilmeli.

- [x] **3.5. Bildirim ve Rezervasyon Listelerinde Alfabetik ID Sıralaması Hatası ([`booking_repository.dart`](lib/data/repositories/booking_repository.dart), [`notification_repository.dart`](lib/data/repositories/notification_repository.dart)):**
  - **Sorun:** `b.id.compareTo(a.id)` alfabetik karşılaştırma yaptığı için `'notif_2'` değeri `'notif_10'` değerinden büyük kabul ediliyor ve sıralama bozuluyor.
  - **Çözüm:** Sıralama ID içerisindeki sayısal değere veya oluşturulma sırasına göre güvenli biçimde yapılmalı.

- [x] **3.6. Bakıcı İlan Sekmesinde (`SitterListingTab`) Birim Etiketinin Sabit "Gecelik" Kalması ([`sitter_sub_tabs.dart`](lib/features/provider/widgets/sitter_sub_tabs.dart)):**
  - **Sorun:** İlan kartında ve düzenleme modalında `sitter.unitLabel` (`gece`, `saat`, `gün`) yerine sabit `"Gecelik Ücret"` metni kullanılıyor.
  - **Çözüm:** Birim etiketi dinamik olarak `sitter.unitLabel` üzerinden gösterilmeli.

---

## 4. Ölü Kodlar (Dead Code), Gereksiz Prop-Drilling ve Kod Temizliği

- [x] **4.1. Hiç Kullanılmayan Dosya ve Sınıfların (Dead Code) Temizlenmesi:**
  - [`lib/app/router/route_names.dart`](lib/app/router/route_names.dart) (`RouteNames` sınıfı hiçbir yerde kullanılmıyor).
  - [`lib/features/splash/controller/splash_controller.dart`](lib/features/splash/controller/splash_controller.dart) (`SplashController` hiçbir yerde kullanılmıyor).
  - [`lib/core/constants/app_dimens.dart`](lib/core/constants/app_dimens.dart) ve [`lib/core/theme/app_colors.dart`](lib/core/theme/app_colors.dart) içindeki hiç referans verilmeyen sabitlerin temizlenmesi.

- [x] **4.2. İşlevsiz Kalan `onProfileTap` ve `discoveryController` Parametrelerinin (Prop-Drilling) Kaldırılması:**
  - **Sorun:**
    - [`PawHeaderActions`](lib/core/widgets/paw_header_actions.dart) içinden profil butonu kaldırıldığı halde `onProfileTap` parametresi silinmemiş ve [`AppShell`](lib/app/router/app_shell.dart) üzerinden **8 ayrı ekrana** boşu boşuna taşınıyor.
    - [`OwnerHomeScreen`](lib/features/home/view/owner_home_screen.dart) içine `discoveryController` geçiriliyor fakat ekran içinde hiç kullanılmıyor.
  - **Çözüm:** İşlevsiz tüm `onProfileTap` ve `discoveryController` parametreleri kaldırılarak widget ağacı sadeleştirilmeli.

- [x] **4.3. Controller ve Alt Sekmelerdeki Kalan Sabit Metinlerin `AppStrings`'e Taşınması:**
  - **Sorun:** [`AuthController`](lib/features/auth/controller/auth_controller.dart), [`BookingsController`](lib/features/bookings/controller/bookings_controller.dart), [`DiscoveryController`](lib/features/discovery/controller/discovery_controller.dart), [`PetsController`](lib/features/pets/controller/pets_controller.dart), [`ProviderController`](lib/features/provider/controller/provider_controller.dart), [`NotificationsController`](lib/features/notifications/controller/notifications_controller.dart) ve [`SitterReviewsTab`](lib/features/provider/widgets/sitter_sub_tabs.dart) içindeki hata mesajları, bildirim metinleri ve yorum verileri doğrudan sınıf içinde Türkçe string olarak bulunuyor.
  - **Çözüm:** Tümü [`AppStrings`](lib/core/constants/app_strings.dart) içerisine taşınarak %100 dil paketi uyumluluğu sağlanmalı.

---

## 5. Yüksek Fayda Sağlayacak Gerekli UI Elementi İhtiyaçları

- [x] **5.1. Keşfet (`ExploreScreen`) İçin "Sonuç Bulunamadı & Filtreleri Sıfırla" Boş Durum Kartı ([`explore_screen.dart`](lib/features/discovery/view/explore_screen.dart)):**
  - **İhtiyaç:** Arama veya bütçe/kategori filtrelemesi sonucunda eşleşen ilan kalmadığında (`sitters.isEmpty`) ekranın alt kısmı tamamen boş kalıyor.
  - **Çözüm:** Eşleşen hizmet bulunamadığında kullanıcıya durumu açıklayan ve tek dokunuşla `controller.resetFilters()` çalıştıran bir **"Filtreleri Temizle"** butonuna sahip boş durum kartı eklenmeli.

- [x] **5.2. Bakıcı Panelinde (`ActiveGuestCardSection`) Tüm Onaylı Konukların Listelenmesi ([`sitter_dashboard_sections.dart`](lib/features/provider/widgets/sitter_dashboard_sections.dart)):**
  - **İhtiyaç:** Şu anda `confirmedBookings.firstOrNull` kullanıldığı için bakıcı yeni bir talebi onayladığında dahi listede yalnızca **tek bir** onaylı konuk gösteriliyor; diğer onaylı konuklar gizli kalıyor.
  - **Çözüm:** `ActiveGuestCardSection` tüm `confirmedBookings` listesini gösterecek şekilde güncellenmeli (hiç onaylı konuk yoksa temiz bir boş durum kartı gösterilmeli).

- [x] **5.3. Sahip Rezervasyon Kartlarında (`OwnerBookingCard`) Tarih Aralığının Gösterilmesi ([`owner_booking_card.dart`](lib/features/bookings/widgets/owner_booking_card.dart)):**
  - **İhtiyaç:** `Taleplerim` ekranındaki kartlarda rezervasyonun hangi tarihler arasında (`startDate - endDate`) yapıldığı bilgisi yer almıyor.
  - **Çözüm:** `OwnerBookingCard` içerisine rezervasyon tarih aralığını (ör. `24 Ekim - 26 Ekim 2026`) gösteren kompakt bir tarih satırı eklenmeli.

- [x] **5.4. Ana Sayfada (`TodaysReservationLiveCard`) Aktif Onaylı Rezervasyon Yokken Gerçekçi Durum Gösterimi ([`owner_home_sections.dart`](lib/features/home/widgets/owner_home_sections.dart)):**
  - **İhtiyaç:** Tüm rezervasyonlar iptal edilse veya reddedilse bile (`activeBooking == null`), ana sayfadaki kart hâlâ "Yürüyüşte • Canlı" rozetiyle varsayılan Mert Demir kartını gösteriyor.
  - **Çözüm:** `activeBooking == null` olduğunda sahte canlı takip göstermek yerine kullanıcıyı `Keşfet` sekmesine yönlendiren şık bir **"Bugün İçin Aktif Rezervasyon Yok — Hizmet Keşfet"** bilgi kartı gösterilmeli.


## 6. Uygulanan Çözümler ve Doğrulama Kaydı

| Madde | Uygulanan sonuç | Doğrulama |
|---|---|---|
| 1.1 | Sohbet kaydı sonrasında `mounted`; kaydırmada post-frame, `mounted` ve `hasClients` kontrolü | `core_chat_test.dart` |
| 1.2 | Nabız controller'ı yalnız aktif rezervasyon rozetiyle oluşur ve kart kalkınca dispose edilir | `ui_regression_test.dart` |
| 1.3 | Dinamik seed listeleri fabrika metotları; kutu bazlı tembel fallback ve temizleme metodu | `data_repositories_test.dart` |
| 1.4 | Başarılı kayıttan sonra kullanılmayan uygulama fotoğrafı ve FileImage/avatar önbelleği temizlenir; köpek/rezervasyon referansları ve galeri asılları korunur | `pets_controller_test.dart`, `data_image_storage_test.dart` |
| 2.1 | Home rezervasyon/sahip adı, Pets köpek listesi ve Provider bakıcı adı cache üzerinde tutulur | `controller_sync_test.dart`, `pets_controller_test.dart` |
| 2.2 | Görsel yüklemede senkron dosya sorgusu yok; eksik dosyada asenkron paket görseli | `data_image_storage_test.dart`, kaynak taraması |
| 2.3 | Açık/koyu `ThemeData` değerleri `static final` olarak tek kez oluşturulur | Analiz ve tema kullanan widget testleri |
| 2.4 | Sohbet/giriş/kayıt modallarında tam ekran blur kaldırıldı; modal bariyeri korundu | Kaynak denetimi ve sohbet widget testleri |
| 3.1 | Aktif köpek varsayılanı seed kaydının `dog_1` kimliğiyle eşit | `data_repositories_test.dart` |
| 3.2 | **KISMİ:** Callback ve panel adı yenileniyor; bakıcı profil adı SitterListing.name alanına yazılmadığından Home/Keşfet ilanları eski adı gösteriyor | Mevcut test yalnız panel adını doğruluyor; ek denetim senaryosu eksikliği yeniden üretti |
| 3.3 | **KISMİ:** Bakıcılar arasında ayrım ve gönderici rolü doğru; aynı bakıcıya bağlı farklı sahipler aynı sitterId anahtarını kullandığından tam muhatap ayrımı yok | Mevcut testler farklı bakıcıları kapsıyor; ek denetim senaryosu farklı sahiplerde ortak geçmişi doğruladı |
| 3.4 | Dolu günleri kapsayan ileri/geri ve aylar arası aralıklar engellenir; eksik/geçersiz tarih gönderilemez; kayıt anında güncel müsaitlik okunur | `core_calendar_test.dart`, `ui_regression_test.dart`, `controller_sync_test.dart` |
| 3.5 | Rezervasyon ve bildirim ID'leri sayısal soneklerine göre sıralanır | `data_repositories_test.dart` |
| 3.6 | İlan kartı ve düzenleme formu gerçek `unitLabel` değerini gösterir | `ui_regression_test.dart` |
| 4.1 | Kullanılmayan RouteNames/SplashController ve 5 ölçü sabiti kaldırıldı; bütün AppColors sabitleri kullanıldığı için korundu | Referans taraması, analiz |
| 4.2 | İşlevsiz `onProfileTap` zinciri ve OwnerHomeScreen `discoveryController` parametresi kaldırıldı | Referans taraması, analiz |
| 4.3 | Controller hata/bildirim metinleri, yorumlar ve parametreli UI biçimleri `AppStrings`'e taşındı | Kaynak taraması, analiz ve widget testleri |
| 5.1 | Keşfet boş durumunda filtreleri ve arama kutusunu temizleyen aksiyon | `ui_regression_test.dart` |
| 5.2 | Bütün onaylı konuklar listelenir; boş listede açıklayıcı kart görünür | `ui_regression_test.dart` |
| 5.3 | Rezervasyon kartları Türkçe tarih aralığını gösterir; farklı yıllar korunur; dar yerleşim taşmaz | `ui_regression_test.dart`, `controller_sync_test.dart` |
| 5.4 | Bugüne ait onaylı kayıt yokken sahte canlı kart yerine hizmet keşfetme kartı | `ui_regression_test.dart`, `controller_sync_test.dart` |

Ek onarımlar: yeni kayıt sonrasında cache isimleri yenilenir; bakıcı aylık kazancı sabit başlangıç tutarı olmadan yalnız ilgili ayın onaylı kayıtlarından hesaplanır; dar sohbet ve rezervasyon kartı taşmaları giderildi.

**Son doğrulama:** `flutter analyze --no-pub` sorunsuz, `flutter test --no-pub` **40/40 başarılı**, Dart biçimlendirme kontrolü temiz. Ayrıntılı test listesi [`yapilanlar.md`](yapilanlar.md) içindedir. Kaynaklar 64 Dart dosyasıdır; kaynak geneline yazılmış literal satır sonu, referanssız AppDimens/AppColors skaler sabiti veya işlevsiz `onProfileTap` kalmamıştır.


## 7. Kullanıcı Talebiyle Yapılan Bağımsız Yeniden Denetim — 25 Ekim 2026

Önceki 21/21 beyanı fazla kesindi. Maddeler uygulamayla yeniden karşılaştırıldı; aşağıdaki açıklar kaynak değiştirilmeden iki ek yeniden üretim senaryosuyla doğrulandı:

- **3.2 — Profil/ilan adı:** `ProfileController.updateActiveUserProfile` bakıcı adını yalnız SettingsRepository'ye kaydediyor. Panel `sitterDisplayName` alanından yeni adı gösterirken Home/Keşfet ve `primarySitter.name` eski ilan adını koruyor. Profil adı ile ilgili güncel ilan kimliğinin nasıl eşitleneceği uygulanmalı ve ilanları kontrol eden regresyon testi eklenmeli. Geçmiş rezervasyonların snapshot adları bu bulgudan ayrı değerlendirilir.
- **3.3 — Muhatap ayrımı:** Farklı bakıcıların konuşmaları ayrılıyor, rol bazlı gönderici de doğru. Ancak bakıcı panelindeki iki farklı sahip için de yalnız `booking.sitterId` gönderiliyor; ilk sahibin konuşması ikinci sahibin başlığı altında görüntülenebiliyor. Tek sahipli demo verisi bu açığı gizliyor. Genel muhatap bazlı gereksinim için iki tarafı ayıran kararlı bir konuşma kimliği ve iki sahipli test gerekli.

**Tekrar çalıştırılan kontroller:** Mevcut 40 test başarılı; analiz 0 sorun, biçimlendirme ve diff kontrolü temiz. Bu sonuçlar yukarıdaki senaryoların kapsandığı anlamına gelmiyor: mevcut profil testi sadece panel adını, sohbet testleri farklı bakıcı anahtarlarını kontrol ediyor. Uygulama kaynaklarına bu denetimde müdahale edilmedi.

**Kapsam notları:** Metinleri AppStrings'e taşıma tamam; çalışan bir dil seçici/çok dilli locale sistemi kurulduğu iddia edilmez. Dolu gün üzerinden kullanıcı seçimi ve geçersiz rezervasyon kaydı engelleniyor; bileşene dışarıdan geçersiz seçili aralık verilirse takvim bunu görsel olarak temizlemiyor. Aktif kayıt hesabı gün bazlıdır; saatlik rezervasyonların bitiş saati ve gece yarısı otomatik yenilemesi ayrıca ele alınabilir. Bunlar ilk rapordaki somut düzeltmelerden ayrı sınırlardır.
