# PawCare — Flutter Teknolojileri, SOLID ve Kod Kalite Kuralları (`skills.md`)

Bu dosya, projede hangi teknolojinin nerede kullanılacağını, SOLID/OOP prensiplerini ve katı tema/stil/ölçü/metin kurallarını tanımlar. Belirtilmeyen yeni bir paket, alternatif bir kütüphane veya gereksiz bir bağımlılık **kesinlikle eklenmez**.

---

## 1. Zorunlu ve İzin Verilen Teknolojiler (Sıfır Gereksiz Bağımlılık)

Projede backend yoktur. Yerel depolama olarak `Hive` kullanıldığı için **JSON dosyaları (`assets/*.json`), `shared_preferences`, `table_calendar`, `flutter_bloc` veya `go_router` KULLANILMAYACAKTIR.**

| Teknoloji | Kullanım Alanı |
|---|---|
| **Flutter / Dart SDK** | Tüm mobil arayüz, özel takvim bileşeni (`PawDateRangeCalendar`), animasyonlar, yönlendirme ve uygulama mantığı |
| **`ValueNotifier` / `ValueListenableBuilder`** | Harici state paketi olmadan reaktif, hafif ve SOLID uyumlu durum yönetimi (`HomeController`, `DiscoveryController`, `PetsController`, `BookingsController`, `ProviderController`, `ProfileController`, `NotificationsController`, `ThemeController`) |
| **`hive` & `hive_flutter`** | Uygulamadaki **TEK** yerel veritabanı (`dogs_box`, `sitters_box`, `bookings_box`, `notifications_box`, `settings_box`) |
| **`image_picker`** | Cihazdan veya kameradan köpek fotoğrafı seçme |
| **`path_provider`** | Seçilen köpek fotoğrafını geçici önbellekten kalıcı uygulama dizinine (`pawcare_pets/`) kopyalama |

---

## 2. Birinci Derece Kod ve Tasarım Kırmızı Çizgileri

### 2.1. Ekran İçinde Metin (`text`), Renk (`Color`), Yazı Kalınlığı (`FontWeight`) ve Sayısal Ölçü Yasağı
- `lib/core/constants/app_strings.dart` (`AppStrings`) dışındaki hiçbir ekran veya widget dosyasında doğrudan kullanıcı arayüzü metni (`Text('...')`, `hintText: '...'`, `labelText: '...'`) **YAZILAMAZ**; tüm statik ve parametreli metinler `AppStrings` üzerinden çağrılır.
- `lib/core/theme/` klasörü dışındaki **HİÇBİR `.dart` dosyasında** `Color(0x...)`, `Colors.xxx`, `FontWeight.w600`, `fontSize: 16` veya satır içi `TextStyle(...)` **YAZILAMAZ**.
- `lib/core/constants/app_dimens.dart` dışındaki **HİÇBİR `.dart` dosyasında** doğrudan sayısal `padding`, `margin`, `width`, `height`, `borderRadius`, `SizedBox` veya `alpha` sabiti **YAZILAMAZ**; tümü `AppDimens` üzerinden çağrılır.
- Tüm renkler `Theme.of(context).colorScheme` (`context.colors`) ve `Theme.of(context).extension<PawThemeExtension>()!` (`context.pawTheme`) üzerinden alınır.
- Tüm metin stilleri ve kalınlıkları `lib/core/theme/app_typography.dart` içinde tanımlanır ve ekranlarda yalnızca `Theme.of(context).textTheme` (`context.pawTextTheme`) üzerinden çağrılır.

### 2.2. JSON Kullanımı Yasaktır (Saf Hive Mimarisi)
- Projede backend olmadığı için `.json` varlık dosyası oluşturulmaz, `dart:convert` ile JSON parse edilmez, modellere gereksiz `fromJson` / `toJson` yazılmaz.
- Başlangıç (demo) hizmet veren ilanları ve örnek kayıtlar `lib/data/local/hive_seed_data.dart` içinde saf Dart nesneleri olarak tanımlanır ve uygulama ilk açıldığında `Hive` kutuları boşsa doğrudan Hive içine tohumlanır (`seed`).

### 2.3. SOLID, OOP ve Tek Widget (DRY) Prensibi
- **Single Responsibility (Tek Sorumluluk):** Hiçbir `build` metodu **40 satırı** geçemez (kaynak dosyalarında denetlenir). Uzun ekranlar küçük yardımcı metodlara (`_build...`) veya `widgets/` altında modüler sınıflara bölünür.
- **Tek İş = Tek Widget (DRY):** Aynı işi yapan iki ayrı widget yazılamaz. Ortak kartlar, butonlar, durum rozetleri, üst bar aksiyonları ve özel rezervasyon takvimi `lib/core/widgets/` altında tek bir kez yazılır ve her yerde kullanılır.
- **Katman Ayrımı:** View katmanı doğrudan `Hive` kutularına erişemez (`View → Controller → Repository → Hive`).

---

## 3. En Sıkı `flutter analyze` ve Lint Kuralları (`analysis_options.yaml`)

Projede 0 hata ve 0 uyarı zorunludur. `analysis_options.yaml` aşağıdaki kuralları zorunlu kılar:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    deprecated_member_use: error
    prefer_const_constructors: error
    prefer_const_declarations: error
    unused_import: error
    unused_local_variable: error

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_fields
    - prefer_final_locals
    - avoid_print
    - avoid_unnecessary_containers
    - use_key_in_widget_constructors
    - sized_box_for_whitespace
```


## 4. Kaynak Onarımı ve Regresyon Kontrolleri

- Dosya üretimi veya metin taşıma sırasında dosyanın bütününü tek satırlık literal `\n` dizilerine dönüştürme. String içindeki kaçışlarla kaynak satır sonlarını ayrı ele al; Dart ayrıştırıcısı ve biçimlendiriciyle doğrula.
- `AppStrings` sadece widget etiketlerini değil controller hata/bildirim metinlerini ve parametreli tarih/ücret biçimlerini de içerir. Kimlik, dosya yolu ve Hive anahtarları kullanıcı metni sayılmaz; seed dosyası demo kayıtlarını barındırır.
- Getter veya `build` içinde Hive ayrıştırması ve senkron dosya varlık sorgusu yapılmaz. Yenileme veri değişikliği sınırında yürütülür.
- Asenkron UI işleminden sonra `mounted` kontrolü yapılır; kaydırma post-frame içinde, bağlı controller üzerinde uygulanır.
- Fotoğraf temizliği yalnız uygulamanın sahip olduğu dizinde yapılır; önce yeni kayıt kalıcılaştırılır, sonra artık kullanılmayan eski dosya ve görsel önbelleği temizlenir.
- Testler `HiveBoxes.clearFallbackMemory()` ile birbirinden yalıtılır. Kalıcılık testleri geçici gerçek Hive kutularını da kapatıp açar.
- `flutter analyze`, `flutter test` ve `dart format --output=none --set-exit-if-changed lib test` sonuçları doğrulanmadan tamamlandı beyanı yazılmaz.
