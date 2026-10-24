# PawCare — Proje Tanımı (`project.md`)

## 1. Projenin Amacı

PawCare, köpek sahiplerini köpek otelleri, günlük bakım hizmetleri ve köpek gezdiricileriyle buluşturan Flutter mobil uygulamasıdır. Kullanıcılar birden fazla köpeğin profilini, dijital mikroçip kimliğini ve sağlık/aşı bilgilerini yönetebilir, hizmetleri gelişmiş filtrelerle inceleyebilir ve rezervasyon talebi oluşturabilir. Hizmet verenler ilanlarını, ücretlerini, müsaitlik takvimlerini, müşteri değerlendirmelerini ve rezervasyon taleplerini yönetebilir.

Proje, saf Flutter/Dart ve **yalnızca `Hive` yerel depolaması** kullanılarak geliştirilmiştir. Harici backend, sunucu veya JSON dosyaları kullanılmamaktadır.

---

## 2. Kullanıcı Rolleri ve Kimlik Senkronizasyonu

- **Köpek Sahibi (`Aygen Y.` — `aygen@pawcare.com`):** Köpeklerini (düzenleme, yeni köpek ekleme, Ana Sayfa ve Köpeklerim sekmesinden aktif köpek seçimi) ve sağlık bilgilerini yönetir, hizmet arar, özel takvim üzerinden seçtiği köpek için rezervasyon oluşturur, bekleyen talepleri iptal edebilir ve bakıcıyla mesajlaşabilir.
- **Hizmet Veren (`Ayşe Yılmaz` — `ayse@mutlupatiler.com`):** Hizmet ilanını, fiyatlarını, müsaitlik takvimini, gelen rezervasyon taleplerini (köpeğin gerçek fotoğrafı ve sahip adıyla Onayla/Reddet) ve aktif konuklarını yönetir; onaylanan rezervasyonlardan doğan aylık kazancını ve müşteri değerlendirmelerini takip eder.

Rol değiştirildiğinde hem alt navigasyon barındaki 5 sekme hem de Profil ve Ana Sayfa ekranlarındaki kullanıcı kimliği/avatarı anında aktif role göre güncellenir.

---

## 3. Temel Özellikler

- Karşılama, giriş ve kayıt arayüzleri (Modal tabanlı, seçilen role göre profil kaydı).
- Merkezi `AppStrings` (`lib/core/constants/app_strings.dart`) sınıfı üzerinden çoklu dil (`i18n` / `l10n`) hazırlığı; UI bileşenleri içinde doğrudan gömülü metin bulunmaz.
- Çoklu köpek profili yönetimi (`AddDogModal`, `EditDogProfileModal`, `DogSelectorChipsRow`), kalıcı cihaz fotoğrafı (`image_picker` + `path_provider`), interaktif aşı kayıtları (`HealthCardModal`), QR dijital mikroçip kimliği (`MicrochipIdentityModal`) ve özel bakım notları.
- Otel, gündüz bakım ve gezdirme hizmetlerini arama, kategoriye/maksimum bütçeye/fiyat sıralamasına göre filtreleme (`_ExploreFilterModal`), dinamik sonuç sayacı (`_ExploreCountBanner`) ve inceleme.
- Saf Flutter ile geliştirilmiş özel tarih aralığı seçici takvim (`PawDateRangeCalendar`) ve köpek seçici (`SitterPetSelectionCard`) üzerinden rezervasyon talebi oluşturma.
- Beklemede, Onaylandı, Reddedildi ve Tamamlandı rezervasyon durumları; bekleyen talepleri iptal etme ve bakıcıya mesaj gönderme.
- Hizmet veren paneli, ilan/ücret düzenleme (`_EditSitterListingModal`), müsaitlik yönetimi, dinamik kazanç/aktif konuk takibi ve doğrulanmış müşteri değerlendirmeleri (`_ReviewsListSection`).
- Profil hesap düzenleme (`EditUserProfileModal`), Ödeme Yöntemleri / Gizlilik & Güvenlik / Yardım & Destek modalları (`ProfileInfoModal`) ve yerel bildirim arayüzleri.
- Splash ekranı ve Açık / Koyu Yeşil (Haki) tema desteği.

---

## 4. Tasarım ve Kod Kalite İlkeleri

- Stitch'te hazırlanmış mevcut 6 ekran tasarımı temel görsel referanstır (`docs/design-system.md`).
- **Merkezi Tema, Tipografi, Boyut ve Metin Zorunluluğu:** `lib/core/theme/`, `lib/core/constants/app_dimens.dart` ve `lib/core/constants/app_strings.dart` dışındaki hiçbir dosyada doğrudan renk kodu (`Color`, `Colors`), yazı kalınlığı/boyutu (`FontWeight`, `fontSize`, `TextStyle`), sayısal ölçü (`padding`, `margin`, `width`, `height`, `radius`) veya UI metin sabiti tanımlanamaz.
- Üstteki geçici yeşil **“Ekranlar”** çubuğu ve alt navigasyon barıyla mükerrer olan yönlendirme blokları (`Popüler Hizmetler`, `Hızlı Yönetim`, üst bar profil ikonu) kaldırılmış; ana navigasyon için 5 sekmeli alt navigasyon barı (`PawBottomNav`) kullanılmıştır.
- Sağ üstte okunmamış bildirim rozetli bildirim ikonu (`PawHeaderActions`) bulunur.
- Açık ve koyu tema desteklenir. Koyu tema tamamen siyah değil, koyu yeşil/haki tonlarındadır (`#16241A`).

---

## 5. Veri ve Kapsam (Saf Hive)

- Hizmet verenlerin başlangıç verileri, köpek profilleri, rezervasyonlar, bildirimler ve tema/rol/kullanıcı ayarları **yalnızca `Hive`** üzerinde saklanır. JSON dosyası veya `shared_preferences` kullanılmaz.
- Rezervasyon talepleri, köpek profilleri ve ilan güncellemeleri aynı cihazdaki köpek sahibi ve hizmet veren görünümlerinde ortak `Hive` kutuları üzerinden anlık takip edilir.
- Bu proje gerçek bir sunucuya, çevrim içi kimlik doğrulamaya, gerçek zamanlı GPS takibine veya uzaktan bildirim altyapısına sahipmiş gibi davranmaz; tüm akışlar yerel Hive veritabanı üzerinde gerçekçi ve kalıcı olarak çalışır.

---

## 6. Başarı Ölçütü ve İlerleme Takibi (`yapilanlar.md` & `eksiklikler.md`)

- Geliştirme adımları kök dizindeki `yapilanlar.md`, 21 teknik denetim maddesi `eksiklikler.md` dosyasında takip edilir. Tamamlanma durumu son doğrulama kaydıyla birlikte değerlendirilir.
- Uygulama SOLID prensiplerine uygun, sıfır `flutter analyze` hatasına sahip, tüm birim ve widget testlerinden (`flutter test`) geçen, tutarlı tasarımlı ve kalıcı yerel verilere sahip durumdadır.


## 7. Kesinti Sonrası Davranışlar — 25 Ekim 2026

Keşfet sonuçsuz kaldığında filtreleri ve arama kutusunu sıfırlayan boş durum kartı görünür. Rezervasyon kartları tarih aralığını gösterir; bakıcı paneli tüm onaylı konukları listeler. Ana sayfada yalnız bugün tarih aralığında olan onaylı rezervasyon aktif gösterilir; aksi durumda hizmet keşfetme kartı çıkar ve nabız animasyonu çalışmaz. Onay, iptal ve profil değişiklikleri diğer sekmelere yansır.

Sohbet geçmişi bakıcı kimliğine göre ayrılır ve rol değişiminde mesaj göndericisi korunur. Rezervasyon takvimi dolu günlerin üzerinden aralık seçilmesini engeller; eksik veya geçersiz tarihlerle gönderim kapatılır ve kayıt anında müsaitlik yeniden doğrulanır. Ücret birimleri ilana göre `gece`, `saat` veya `gün` olarak görünür. Bakıcı kazancı, ilgili ayda başlayan onaylı kayıtlardan hesaplanır; başlangıç toplamı sıfırdır.

`AppStrings` merkezi Türkçe metin kaynağıdır; başka dil paketleri veya çalışan bir dil seçici bu kapsamda eklenmemiştir. Hive ve yerel demo kapsamı korunmuştur. Son test ve analiz sonuçları [`yapilanlar.md`](../yapilanlar.md) içindedir.


### Yeniden denetim notu — 25 Ekim 2026

Mevcut 40 test ve analiz temiz olsa da 3.2 ve 3.3 maddeleri yeniden açılmıştır. Bakıcı profil adı panelde değişir; Home/Keşfet ilanındaki ad eski kalır. Sohbet geçmişi bakıcıya göre ayrılır ancak aynı bakıcıyla görüşen farklı sahipler için ayrı konuşma kimliği yoktur. Genel tamamlanma beyanı bu iki açık giderilene kadar geçerli değildir; kayıt `eksiklikler.md` bölüm 7 içindedir.
