# PawCare — Flutter Teknolojileri ve Kullanım Kuralları

Bu dosya, projede hangi Flutter teknolojisinin nerede ve ne amaçla kullanılacağını tanımlar. Belirtilmeyen yeni bir paket, mevcut paketlerin yerine geçecek alternatif veya gereksiz bir teknoloji eklenmez.

## 1. Zorunlu teknolojiler

| Teknoloji | Kullanım alanı |
|---|---|
| Flutter / Dart | Tüm mobil arayüz ve uygulama mantığı |
| `go_router` | Sayfalar, alt navigasyon ve yönlendirme |
| `flutter_bloc` / Cubit | Ekran durumları ve kullanıcı işlemleri |
| `hive` | Kullanıcı tarafından oluşturulan veya değiştirilen yerel veriler |
| JSON assets | Başlangıç hizmet ilanları ve sabit demo verileri |
| `table_calendar` | Rezervasyon tarih aralığı ve müsaitlik takvimi |
| `image_picker` | Cihazdan köpek fotoğrafı seçme |
| `shared_preferences` | Yalnızca küçük ayarlar; ör. seçilen tema veya ilk açılış bilgisi |

Paketler önce mevcut `pubspec.yaml` dosyasından kontrol edilir. Aynı işlev için ikinci bir paket eklenmez.

## 2. Teknolojilerin kullanım kuralları

### GoRouter
- Tam ekran sayfalar ve alt navigasyon hedefleri için kullanılır.
- Route adları ve yolları merkezi olarak tanımlanır.
- Modal açmak için her etkileşimde yeni route oluşturulmaz; uygun durumlarda Flutter dialog/bottom sheet kullanılır.
- Geri gezinme ve doğrudan URL ile açılabilen sayfalar kontrol edilir.

### Cubit
- Yükleniyor, başarılı, boş ve hata durumlarını yönetir.
- View içindeki iş kurallarını ve veri erişimini azaltır.
- Basit, yalnızca görsel bir widget için gereksiz Cubit oluşturulmaz.
- Birbiriyle ilgili ekranların paylaştığı veri için uygun ortak Cubit/repository tasarımı yapılır.

### Hive
- Köpek profilleri, aşı kayıtları, rezervasyonlar, yerel kullanıcı/demo ayarları gibi değişebilir verileri saklar.
- Modellerin serileştirme yöntemi açıkça tanımlanır.
- Başlatma ve kutu açma işlemleri uygulama başlamadan tamamlanır.
- Hive verisi ile aynı verinin SharedPreferences kopyası oluşturulmaz.

### JSON assets
- Hizmet verenler ve başlangıç ilanları gibi uygulamayla gelen veriler için kullanılır.
- JSON verisi repository üzerinden okunur ve modele dönüştürülür.
- Başlangıç verileri, kullanıcının Hive'da saklanan değişikliklerinin üzerine her açılışta yazılmaz.

### SharedPreferences
- Tema tercihi ve küçük, basit ayarlar için kullanılır.
- Rezervasyonlar veya karmaşık listeler için ana veritabanı olarak kullanılmaz.

### `table_calendar`
- Tarih seçimi ve takvim görünümü için kullanılır.
- Geçmiş tarihler, seçilen tarih aralığı ve müsaitlik kuralları uygulama mantığıyla doğrulanır.

### `image_picker`
- Köpek profiline fotoğraf seçmek için kullanılır.
- İzinler, iptal durumu ve yüklenemeyen görseller ele alınır.
- Fotoğrafın uygulama yeniden açıldığında kullanılabilir kalması hedeflenir; platforma özgü saklama sınırlamaları dikkate alınır.

## 3. Tema ve arayüz

- Açık/koyu tema merkezi `core/theme/` altında yönetilir.
- Renkler ve metin stilleri ortak tema dosyalarından alınır; ekranlara rastgele renkler yazılmaz.
- Splash animasyonu, modal geçişleri ve küçük etkileşimler Flutter'ın yerleşik animasyonlarıyla uygulanır.
- Logo ve tasarım görselleri `assets/` altında tutulur.
- Bildirim ve profil ikonlarının görünümü hazırlanır; gerçek bildirim altyapısı ayrıca geliştirilmedikçe gerçek bildirim gönderildiği iddia edilmez.

## 4. Veri ve güvenilirlik

- Harici backend, SQL veritabanı veya çevrim içi servis bu projenin kapsamında değildir.
- Demo verisi ile kullanıcı verisi birbirinden ayrılır.
- Rezervasyon durumu değiştiğinde aynı yerel veri kaynağını kullanan ilgili ekranlar güncellenir.
- Veri modellerinde tür güvenliği ve gerekli alan doğrulamaları uygulanır.

## 5. Paket ekleme kuralı

Yeni bir paket yalnızca ihtiyaç mevcut paketlerle karşılanamıyorsa eklenir. Paket eklemeden önce amacı ve etkilediği dosyalar belirlenir. Gereksiz bağımlılıklar, alternatif state-management sistemleri ve aynı işi yapan birden fazla paket kullanılmaz.