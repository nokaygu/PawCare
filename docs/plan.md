# PawCare — Geliştirme Yol Haritası ve Uygulama Planı (`plan.md`)

Bu doküman; `project.md`, `architecture.md`, `skills.md`, `.agents.md` ve `design-system.md` kuralları doğrultusunda, PawCare projesinin mevcut kodunu ve Stitch tasarımını bozmadan hedef mimariye güvenli biçimde taşınması için hazırlanmıştır.

Geliştirme sürecinde ekranların tekrar tekrar düzenlenmesini (tema, navigasyon veya veri için mükerrer iş yapılmasını) önlemek amacıyla adımlar **doğrusal, bağımlılıkları tamamlayarak ilerleyen ve tek seferde entegre eden** bir akışla kurgulanmıştır.

---

## 1. Mimari Karşılaştırma ve Temel Prensipler

### 1.1. Mevcut Yapı ve Eksikler
- **Dizin Düzeni:** `lib/` altında dağınık ve monolitik yapı (`models/`, `screens/`, `state/`, `theme/`, `widgets/`).
- **Durum Yönetimi:** `ChangeNotifier` tabanlı monolitik `AppState`; veriler yalnızca geçici bellekte (in-memory) tutuluyor.
- **Kalıcılık:** Hive ve JSON varlıkları henüz bağlı değil. Seçilen köpek fotoğrafı ve rezervasyon durumları uygulama yeniden açıldığında kayboluyor.
- **Navigasyon:** GoRouter yok. `app_shell.dart` içinde `setState` ile ekran değişimi ve üstte geçici bir yeşil "Ekranlar" demo çubuğu bulunuyor.
- **Tema:** Yalnızca açık tema (`AppColors`) var; haki/koyu yeşil dark mode desteği bulunmuyor.
- **Tasarım:** Mevcut 6 ekran Stitch tasarımına yüksek sadakatle kodlanmış durumdadır; bu görsel hiyerarşi, bileşenler ve renkler kesinlikle korunacaktır.

### 1.2. Mükerrer Değişiklikleri Önleyen Sıralama Mantığı
Ekranları feature klasörlerine taşımadan önce:
1. **Veri ve Kalıcılık Katmanı** tamamlanır (modeller, Hive, kalıcı fotoğraf stratejisi, repository'ler).
2. **Tema ve Tasarım Sistemi** tamamlanır (açık ve koyu yeşil temalar, tipografi, ThemeCubit).
3. **Navigasyon ve İskelet** kurulur (GoRouter rotaları, Shell, alt bar ve standart üst başlık).
4. **Ekranlar Taşınırken** doğrudan bu hazır temaya, yönlendirmeye, üst başlığa ve Cubit'lere bağlanır. Böylece hiçbir ekran tema veya navigasyon için ikinci kez değiştirilmek zorunda kalmaz.





## 2. Faz Bazlı Yol Haritası



### FAZ 1: Veri Katmanı ve Kalıcılık Altyapısı

> **Amaç:** Projeyi gerekli paketlerle donatmak, modelleri taşımak, Hive başlatma sırasını ve kalıcı fotoğraf saklama stratejisini kurmak, repository katmanını oluşturmak.

#### Adım 1.1: Bağımlılıkların ve Asset Yapılandırmasının Güncellenmesi
- **Yapılacak İş:** `pubspec.yaml` dosyasına `go_router`, `flutter_bloc`, `hive`, `hive_flutter`, `path_provider`, `image_picker`, `shared_preferences` paketlerini eklemek; `assets/data/` yolunu varlıklara dahil etmek.
- **Etkilenecek Dosyalar:** `pubspec.yaml`
- **Tamamlanma Kontrolü:** `flutter pub get` hatasız tamamlanmalı.

#### Adım 1.2: Başlangıç Verisinin JSON Varlığına Çıkarılması
- **Yapılacak İş:** `AppState` içindeki statik `_sitters` verisini `assets/data/sitters.json` dosyasına aktarmak.
- **Etkilenecek Dosyalar:** `assets/data/sitters.json`, `pubspec.yaml`
- **Tamamlanma Kontrolü:** JSON dosyasının geçerli yapıda olduğu ve asset olarak yüklenebildiği doğrulanmalı.

#### Adım 1.3: Modellerin Taşınması ve Hive Serileştirmesi
- **Yapılacak İş:** `lib/models/models.dart` içindeki sınıfları (`UserRole`, `Vaccination`, `Dog`, `SitterListing`, `BookingRequest`, `ChatMessage`, `NotificationItem`) `lib/data/models/` altına taşımak; JSON serileştirme ve Hive TypeAdapter/serileştirme yapılandırmalarını eklemek.
- **Etkilenecek Dosyalar:** `lib/data/models/models.dart`
- **Tamamlanma Kontrolü:** Model serileştirme ve kopyalama testleri hatasız çalışmalı.

#### Adım 1.4: Fotoğraf Kalıcılığı ve Hive Başlatma Sırasının Kurulması
- **Yapılacak İş:**
  - **Başlatma Sırası:** `main()` içinde `WidgetsFlutterBinding.ensureInitialized()` → `await Hive.initFlutter()` → Adapter'ların kaydı → Kutuların (`dogs_box`, `bookings_box`, `notifications_box`, `settings_box`) açılması → Başlangıç verisi tohumlama (seed) sırasını kurmak.
  - **Fotoğraf Kalıcılığı:** Cihazdan seçilen fotoğrafın geçici önbellekten (`XFile`) uygulamanın kalıcı belgeler dizinine (`getApplicationDocumentsDirectory() / 'pawcare_pets' / ...`) kopyalanmasını ve kalıcı dosya yolunun Hive'daki `Dog.photoPath` alanına kaydedilmesini sağlayan yardımcı servisi (`ImageStorageService`) yazmak.
  - Arayüzün hem yerel asset (`assets/...`) hem de kalıcı dosya yolunu (`File(...)`) sorunsuz görüntülemesini sağlamak.
- **Etkilenecek Dosyalar:** `lib/data/local/hive_boxes.dart`, `lib/core/utils/image_storage_service.dart`
- **Tamamlanma Kontrolü:** Test ortamında seçilen dosyanın kalıcı yola kopyalandığı ve Hive kaydının yeniden açılışta korunduğu doğrulanmalı.

#### Adım 1.5: Repository Katmanının Oluşturulması
- **Yapılacak İş:** `DogRepository` (Hive), `BookingRepository` (Hive), `SitterRepository` (JSON), `NotificationRepository` (Hive) ve `SettingsRepository` (SharedPreferences / Hive) sınıflarını oluşturmak.
- **Etkilenecek Dosyalar:** `lib/data/repositories/`
- **Tamamlanma Kontrolü:** Repository birim testleri ile veri okuma/yazma işlemleri doğrulanmalı.

> **Faz 1 Sonu Doğrulama:**
> - `flutter analyze` 0 hata vermeli.
> - Veri modelleri, Hive başlatma ve repository testleri (`flutter test`) başarıyla geçmeli.

---

### FAZ 2: Tasarım Sistemi, Tema ve Splash

> **Amaç:** Stitch tasarım kurallarına tam uyumlu açık tema ve koyu yeşil/haki dark mode altyapısını kurmak; animasyonlu PawCare splash ekranını hazırlamak.

#### Adım 2.1: Merkezi Tema Sistemi ve Koyu Yeşil/Haki Dark Mode
- **Yapılacak İş:**
  - `lib/core/theme/app_colors.dart` dosyasını `design-system.md`'deki açık tema tokenları ve koyu tema için belirlenen koyu zeytin/haki paletiyle (`#1E3023`, `#16241A`, `#243628`, `#344638`, `#DCE5D7`, `#EAE8E2`, `#9FB3A1`) yapılandırmak (saf siyah `#000000` kullanılmayacaktır).
  - `lib/core/theme/app_theme.dart` altında Material 3 uyumlu `lightTheme` ve `darkTheme` tanımlamak.
  - `lib/core/theme/app_typography.dart` Nunito Sans stillerini temaya duyarlı renklere bağlamak.
- **Etkilenecek Dosyalar:** `lib/core/theme/app_colors.dart`, `lib/core/theme/app_theme.dart`, `lib/core/theme/app_typography.dart`
- **Tamamlanma Kontrolü:** Açık ve koyu temada metin-arkaplan kontrast oranlarının okunabilirliği kontrol edilmeli.

#### Adım 2.2: Tema Durum Yönetimi (ThemeCubit)
- **Yapılacak İş:** Kullanıcının tema tercihini (Sistem / Açık / Koyu Yeşil) `shared_preferences` üzerinden saklayan ve anlık değiştiren `ThemeCubit`'i oluşturmak.
- **Etkilenecek Dosyalar:** `lib/core/theme/theme_cubit.dart`
- **Tamamlanma Kontrolü:** Tema değişim birim testi ile tercihin kalıcı olduğu doğrulanmalı.

#### Adım 2.3: Animasyonlu PawCare Splash Ekranı
- **Yapılacak İş:**
  - `lib/features/splash/view/splash_page.dart` ve `splash_cubit.dart` oluşturmak.
  - Ekranda PawCare pati logosu, ölçülü parıltı/büyüme animasyonu ve "PawCare" tipografisini yerleştirmek.
  - Hive ve başlangıç verileri hazır olduğunda yönlendirmeyi tetiklemek.
- **Etkilenecek Dosyalar:** `lib/features/splash/`
- **Tamamlanma Kontrolü:** Animasyonun akıcı çalıştığı ve süre bitiminde yönlendirme sinyali verdiği widget testi ile doğrulanmalı.

> **Faz 2 Sonu Doğrulama:**
> - `flutter analyze` hatasız olmalı.
> - Splash animasyon ve tema testleri başarılı olmalı.

---

### FAZ 3: Navigasyon ve Uygulama İskeleti

> **Amaç:** Navigasyonu GoRouter altyapısına geçirmek; üstteki geçici yeşil "Ekranlar" çubuğunu kaldırmak, alt navigasyon çubuğunu bağlamak ve standart üst başlık (profil/bildirim ikonları) şablonunu oluşturmak.

#### Adım 3.1: GoRouter Rota Yapılandırması
- **Yapılacak İş:**
  - `lib/app/router/route_names.dart`: Rota sabitlerini tanımlamak (`splash`, `welcome`, `home`, `explore`, `pets`, `bookings`, `profile`, `sitterDashboard`, `sitterDetail`).
  - `lib/app/router/app_router.dart`: `StatefulShellRoute` veya `ShellRoute` kullanarak alt navigasyonlu ana uygulama çatısını kurmak.
- **Etkilenecek Dosyalar:** `lib/app/router/route_names.dart`, `lib/app/router/app_router.dart`, `lib/app/app.dart`
- **Tamamlanma Kontrolü:** Rota geçiş mantığının doğru dallara ayrıldığı doğrulanmalı.

#### Adım 3.2: Uygulama İskeleti, Alt Bar ve Üst Yeşil Çubuğun Kaldırılması
- **Yapılacak İş:**
  - `AppShell` içerisindeki geçici yeşil "Ekranlar:" demo çubuğunu tamamen kaldırmak.
  - `PawBottomNav` bileşenini `lib/core/widgets/paw_bottom_nav.dart` altına almak ve GoRouter sekme indeksleriyle senkronize etmek.
  - Mobil genişlik sınırlamasını (`maxWidth: 480`) ve safe area düzenini korumak.
- **Etkilenecek Dosyalar:** `lib/app/router/app_shell.dart`, `lib/core/widgets/paw_bottom_nav.dart`
- **Tamamlanma Kontrolü:** Yeşil çubuğun ekrandan tamamen kalktığı ve alt bar sekmelerinin aktif rota ile uyumlu çalıştığı doğrulanmalı.

#### Adım 3.3: Standart Üst Başlık Şablonu (Profil ve Bildirim İkonları)
- **Yapılacak İş:**
  - Ekranlarda kullanılacak ortak başlık eklentisini (`PawHeaderActions` veya standart `AppBar`) hazırlamak.
  - Sağ üst köşeye profil ikonu ve okunmamış bildirim rozetli (badge) bildirim ikonu yerleştirmek.
  - Bu ikonların dokunma aksiyonlarını GoRouter profil rotasına ve bildirim modalına bağlamak.
  - *Böylece ekranlar bir sonraki fazda taşınırken bu başlık doğrudan entegre edilecek, ekranlara sonradan tekrar dönülmeyecektir.*
- **Etkilenecek Dosyalar:** `lib/core/widgets/paw_header_actions.dart`
- **Tamamlanma Kontrolü:** İkonların sağ üstte doğru hizalandığı ve dokunma durumlarının çalıştığı doğrulanmalı.

#### Adım 3.4: Dinamik Rol Yönetimi (RoleCubit)
- **Yapılacak İş:** `RoleCubit` ile aktif rolü (Köpek Sahibi / Hizmet Veren) yönetmek; rol değiştiğinde alt navigasyonun ve yönlendirilen başlangıç ekranının anında güncellenmesini sağlamak.
- **Etkilenecek Dosyalar:** `lib/features/auth/cubit/role_cubit.dart`
- **Tamamlanma Kontrolü:** Rol değişiminde 5 sekmeli sahip veya hizmet veren alt barının doğru görüntülendiği test edilmeli.

> **Faz 3 Sonu Doğrulama:**
> - `flutter analyze` hatasız olmalı.
> - Navigasyon ve alt bar yönlendirme testleri çalışmalı.




### FAZ 4: Özelliklerin Taşınması ve Entegrasyon

> **Amaç:** Mevcut ekranları Stitch tasarım sadakatini koruyarak feature klasörlerine taşımak; tek seferde tema, navigasyon, Cubit ve veri bağlantılarını tamamlamak.

#### Adım 4.1: Karşılama ve Kimlik Doğrulama (`Onboarding` & `Auth`)
- **Yapılacak İş:**
  - `welcome_screen.dart` → `lib/features/onboarding/view/welcome_screen.dart`
  - `login_modal.dart` ve `signup_modal.dart` → `lib/features/auth/widgets/`
  - Demo rol seçimi, hero kartı ve Stitch buton stillerini korumak; `AuthCubit` ile bağlamak.
- **Etkilenecek Dosyalar:** `lib/features/onboarding/`, `lib/features/auth/`
- **Tamamlanma Kontrolü:** Karşılama ekranı açılmalı; modallar ve demo giriş akışı hatasız çalışmalı.

#### Adım 4.2: Köpek Sahibi Ana Sayfası (`Home`)
- **Yapılacak İş:**
  - `owner_home_screen.dart` → `lib/features/home/view/owner_home_screen.dart`
  - Üst başlığa Faz 3'te hazırlanan sağ üst profil ve bildirim ikonlarını yerleştirmek.
  - Canlı rezervasyon nabız (pulse) animasyonunu, aşı uyarısını ve Stitch kartlarını korumak.
  - `HomeCubit` ile aktif köpek ve rezervasyon verilerini Repository'den beslemek.
- **Etkilenecek Dosyalar:** `lib/features/home/`
- **Tamamlanma Kontrolü:** Ana sayfa verileri Hive'dan gelmeli; nabız animasyonu ve başlık butonları çalışmalı.

#### Adım 4.3: Keşfet ve Hizmet Detayı (`Discovery`)
- **Yapılacak İş:**
  - `explore_screen.dart` → `lib/features/discovery/view/explore_screen.dart`
  - `sitter_detail_screen.dart` → `lib/features/discovery/view/sitter_detail_screen.dart`
  - `DiscoveryCubit`: Arama ve kategori filtrelerini `SitterRepository` üzerinden yönetmeli.
  - `TableCalendar` tarih seçimi, fiyat hesaplama ve rezervasyon oluşturma akışını korumak.
  - Üst başlığa profil ve bildirim ikonlarını eklemek.
- **Etkilenecek Dosyalar:** `lib/features/discovery/`
- **Tamamlanma Kontrolü:** Arama ve filtreleme çalışmalı, tarih seçilerek oluşturulan talep `BookingRepository`'ye kaydedilmeli.

#### Adım 4.4: Köpek Profili, Sağlık Kartı ve Fotoğraf Seçimi (`Pets`)
- **Yapılacak İş:**
  - `dog_profile_screen.dart` → `lib/features/pets/view/dog_profile_screen.dart`
  - `health_card_modal.dart` → `lib/features/pets/widgets/health_card_modal.dart`
  - `PetsCubit`: Köpek profilini ve aşıları Hive'da güncellemek.
  - `image_picker` ile seçilen fotoğrafı Faz 1'deki `ImageStorageService` ile kalıcı klasöre kopyalayıp Hive'a kaydetmek; arayüzde anında ve uygulama yeniden açıldığında görünmesini sağlamak.
  - Üst başlık profil/bildirim ikonlarını eklemek.
- **Etkilenecek Dosyalar:** `lib/features/pets/`
- **Tamamlanma Kontrolü:** Fotoğraf seçimi sonrası resmin profil kartında ve yeniden başlatma sonrasında kaybolmadığı doğrulanmalı.

#### Adım 4.5: Hizmet Veren Paneli ve Taleplerin Yönetimi (`Provider`)
- **Yapılacak İş:**
  - `sitter_dashboard_screen.dart` → `lib/features/provider/view/sitter_dashboard_screen.dart`
  - `ProviderCubit`: Bekleyen ve onaylı rezervasyonları `BookingRepository` üzerinden yönetmeli.
  - Onayla ve Reddet aksiyonları aynı Hive kaydını güncellemeli.
  - Üst başlığa profil ve bildirim ikonlarını eklemek.
- **Etkilenecek Dosyalar:** `lib/features/provider/`
- **Tamamlanma Kontrolü:** Sahip tarafından oluşturulan rezervasyon anında bu panelde Beklemede olarak görünmeli; Onayla/Reddet aksiyonları çalışmalı.

#### Adım 4.6: Rezervasyonlarım ve Ortak Modallar (`Bookings` & `Modals`)
- **Yapılacak İş:**
  - `app_shell.dart` içindeki `_buildOwnerBookingsTab` kodunu `lib/features/bookings/view/owner_bookings_screen.dart` dosyasına dönüştürmek; `BookingsCubit`'e bağlamak.
  - Ortak modalları (`chat_modal.dart`, `live_tracking_modal.dart`, `call_modal.dart`) `lib/core/widgets/modals/` altına taşımak.
- **Etkilenecek Dosyalar:** `lib/features/bookings/`, `lib/core/widgets/modals/`
- **Tamamlanma Kontrolü:** Taleplerim sekmesinde rezervasyon durumu değişikliklerinin (Onaylandı/Reddedildi) anında güncellendiği doğrulanmalı.

> **Faz 4 Sonu Doğrulama:**
> - `flutter analyze` hatasız olmalı.
> - Tüm ekranların Stitch tasarım sadakati, köşe yuvarlaklıkları ve kart hiyerarşisi görsel olarak doğrulanmalı.




### FAZ 5: Yerel Bildirimler ve Profil Yönetimi

> **Amaç:** Bildirim kapsamını kesinlikle yerel demo olaylarıyla sınırlı tutarak bildirim ekranını/modalını hazırlamak; profil ayarlarını ve tema değiştiriciyi entegre etmek.

#### Adım 5.1: Yerel Demo Bildirim Tetikleyicileri ve Bildirim Görünümü
- **Tanımlı Yerel Olaylar (Kapsam Sınırı):**
  *Push notification, harici sunucu, Firebase, OneSignal veya GPS servisi KESİNLİKLE eklenmeyecektir.* Bildirimler yalnızca şu 4 yerel olay ile oluşacaktır:
  1. **Rezervasyon Oluşturuldu:** "Rezervasyon talebiniz iletildi: [Hizmet Adı] - Beklemede"
  2. **Rezervasyon Durumu Değişti:** Hizmet veren Onayla/Reddet yaptığında "Rezervasyonunuz onaylandı! 🐾" veya "Rezervasyonunuz reddedildi."
  3. **Aşı Hatırlatıcısı:** "Barley için Karma Aşı zamanı yaklaşıyor (26 Ekim 2026)"
  4. **Demo Yürüyüş Durumu:** "Mert Demir yürüyüş seansını başlattı."
- **Yapılacak İş:**
  - `lib/features/notifications/view/notifications_sheet.dart` (veya modal) ve `notifications_cubit.dart` oluşturmak.
  - Tanımlı yerel olay bildirimlerini listelemek; tıklandığında okundu olarak işaretlemek.
  - Sağ üst bildirim ikonundaki rozetin (badge) okunmamış bildirim sayısına göre güncellenmesini sağlamak.
- **Etkilenecek Dosyalar:** `lib/features/notifications/`, `lib/core/widgets/paw_header_actions.dart`
- **Tamamlanma Kontrolü:** Bildirim ikonuna tıklandığında listenin açıldığı, bildirime tıklanınca okundu olduğu ve rozetin söndüğü doğrulanmalı.

#### Adım 5.2: Profil, Ayarlar ve Tema Değiştirici Ekranı (`Profile`)
- **Yapılacak İş:**
  - `lib/features/profile/view/profile_screen.dart` oluşturmak (mevcut profil sekmesi içeriğini feature haline getirmek).
  - Kullanıcı demo bilgileri, kayıtlı köpek bilgisi, rol değiştirme ve çıkış butonları.
  - **Açık Tema / Koyu Yeşil (Haki Dark Mode) Seçicisi** (Switch veya Segmented Control) eklemek; `ThemeCubit` ile anlık tema geçişi sağlamak.
- **Etkilenecek Dosyalar:** `lib/features/profile/`
- **Tamamlanma Kontrolü:** Profil ekranından tema değiştirildiğinde tüm uygulamanın anında koyu yeşil/haki veya açık moda geçtiği doğrulanmalı.

> **Faz 5 Sonu Doğrulama:**
> - `flutter analyze` hatasız olmalı.
> - Bildirim açılışı, okundu durumu ve tema geçiş kontrolleri test edilmeli.

---

### FAZ 6: Temizlik, Doğrulama ve Test

> **Amaç:** Eski monolitik kodları temizlemek, tüm testleri ve statik analizleri çalıştırmak, Stitch tasarım sadakatini ve koyu yeşil dark mode kontrastını doğrulamak.

#### Adım 6.1: Eski Monolitik Kodların Güvenli Şekilde Temizlenmesi
- **Yapılacak İş:**
  - Eski `lib/state/app_state.dart` dosyasını silmek.
  - Eski `lib/screens/` klasörünü ve taşınmış eski dosyaları silmek.
  - `lib/main.dart` başlangıç dosyasını temizlemek (`MultiRepositoryProvider` ve `MultiBlocProvider` ile sarmalama).
  - Kullanılmayan import veya geçici kod kalmadığını kontrol etmek.
- **Etkilenecek Dosyalar:** `lib/main.dart`, `lib/state/`, `lib/screens/`
- **Tamamlanma Kontrolü:** Projede hiçbir kırık import veya tanımsız referans kalmamalı.

#### Adım 6.2: 6 Stitch Ekranının Tasarım Sadakati ve Etkileşim Denetimi 
- **Yapılacak İş:**
  - Ekran 1 (Karşılama), Ekran 2 (Keşfet), Ekran 3 (Sahip Ana Sayfa), Ekran 4 (Detay & Rezervasyon), Ekran 5 (Köpek Profili), Ekran 6 (Hizmet Veren Paneli) tasarımlarını `design-system.md` kriterleriyle tek tek karşılaştırmak.
  - Nunito Sans tipografi, köşe yuvarlaklıkları (18–22 px kartlar, oval etiketler), gölgeler ve buton etkileşimlerini doğrulamak.
- **Etkilenecek Dosyalar:** Tüm `features/` ekranları.
- **Tamamlanma Kontrolü:** Tasarım kontrol listesi üzerinden görsel bütünlük teyit edilmeli.

#### Adım 6.3: Koyu Tema (Haki/Koyu Yeşil) ve Açık Tema Kontrast Denetimi
- **Yapılacak İş:**
  - Tüm ekranların hem açık hem koyu yeşil modda okunabilirliğini denetlemek.
  - Koyu temada hiçbir alanda saf siyah (`#000000`) veya aşırı neon parlama olmadığını teyit etmek.
- **Etkilenecek Dosyalar:** `lib/core/theme/`
- **Tamamlanma Kontrolü:** İki temada da bileşenlerin uyumlu ve okunabilir olduğu doğrulanmalı.

#### Adım 6.4: Format, Statik Analiz ve Nihai Test Paketi
- **Yapılacak İş:**
  - `dart format .` çalıştırmak.
  - `flutter analyze` çalıştırmak (0 hata, 0 lint uyarısı).
  - `flutter test` ile tüm birim, cubit ve widget testlerini çalıştırmak.
- **Etkilenecek Dosyalar:** Tüm proje.
- **Tamamlanma Kontrolü:** Tüm komutların başarıyla sıfır hata ile tamamlanması.

#### Adım 6.5: Proje Dokümantasyonu (README.md) Yazımı
- **Yapılacak İş:** Projenin amacını, mimarisini (Feature-first + Cubit + Hive), kurulum adımlarını, ekran görüntülerini ve özelliklerini açıklayan öz ve profesyonel bir `README.md` hazırlamak.
- **Etkilenecek Dosyalar:** `README.md`
- **Tamamlanma Kontrolü:** `README.md` dosyasının projenin güncel durumunu doğru yansıtacak şekilde tamamlanması.

---

## 3. Belirsizlikler, Kararlar ve Mimari İlkeler

1. **Köpek Fotoğrafı Kalıcılığı (Kalıcı Dosya Kopyalama Yaklaşımı):**
   `image_picker` ile seçilen resimler cihazın geçici dizininde tutulduğunda uygulama yeniden başladığında kaybolma riski taşır. Bu durum tek bir kesin yaklaşımla çözülmüştür: Seçilen resim `path_provider` ile uygulamanın kalıcı belgeler dizinine (`app_docs/pawcare_pets/`) kopyalanacak ve Hive'da bu kalıcı dosya yolu saklanacaktır. Arayüzde `photoPath.startsWith('assets/')` kontrolüyle hem başlangıç varlıkları (`AssetImage`) hem de özel fotoğraflar (`FileImage`) hatasız render edilecektir.

2. **Yerel Demo Bildirim Sınırı:**
   Projede push notification veya backend bulunmamaktadır. Bildirimler yalnızca 4 yerel olayla (rezervasyon oluşturma, onay/ret durumu değişimi, aşı uyarısı ve yürüyüş durumu) tetiklenen yerel demo bildirimleriyle sınırlandırılmıştır.

3. **Koyu Tema (Dark Mode) Renk Yelpazesi:**
   `project.md` koyu temanın siyah değil koyu yeşil/haki olmasını şart koşmaktadır. Stitch renk sistemiyle uyumlu olarak zeminler `#16241A` ve `#1E3023`, kart yüzeyleri `#243628` ve `#344638`, vurgular adaçayı (`#DCE5D7`) ve açık zeytin (`#9FB3A1`) olarak belirlenmiştir.

4. **`sitters.json` Dosya Konumu:**
   `architecture.md` hedef klasör yapısıyla uyumlu olarak `assets/data/sitters.json` yolu kullanılacak ve `pubspec.yaml` varlık tanımlarına eklenecektir.

5. **Ekranların Taşınma Sırası ve Mükerrer Değişikliklerin Önlenmesi:**
   Tasarım sistemi (Tema), Navigasyon (GoRouter) ve Üst Başlık (Profil/Bildirim ikonları) ekranlar taşınmadan önce hazırlandığı için, her ekran feature klasörüne taşınırken tek seferde bu nihai altyapıyla entegre edilecek; tema veya navigasyon için geriye dönük tekrar değişiklik yapılmayacaktır.
