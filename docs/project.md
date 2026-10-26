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
- Çoklu köpek profili yönetimi (`AddDogModal`, `EditDogProfileModal`, `DogSelectorChipsRow`), kalıcı cihaz fotoğrafı (`image_picker` + `path_provider`), interaktif aşı kayıtları (`HealthCardModal`), metin mikroçip kimliği (`MicrochipIdentityModal`) ve özel bakım notları.
- Otel, gündüz bakım ve gezdirme hizmetlerini arama, kategoriye/maksimum bütçeye/fiyat sıralamasına göre filtreleme (`DiscoveryFilterModal`), dinamik sonuç sayacı (`_ExploreCountBanner`) ve inceleme.
- Saf Flutter ile geliştirilmiş özel tarih aralığı seçici takvim (`PawDateRangeCalendar`) ve köpek seçici (`SitterPetSelectionCard`) üzerinden rezervasyon talebi oluşturma.
- Beklemede, Onaylandı, Reddedildi, İptal Edildi ve Tamamlandı durumları; bekleyen veya henüz başlamamış onaylı rezervasyonları iptal etme ve bakıcıya mesaj gönderme.
- Hizmet veren paneli, ilan/ücret düzenleme (`_EditSitterListingModal`), müsaitlik yönetimi, onaylı brüt toplam/aktif konuk takibi, hizmet tamamlama ve örnek müşteri değerlendirmeleri (`_ReviewsListSection`).
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

- Geliştirme adımları kök dizindeki `yapilanlar.md`, yeni 50 maddelik denetim `eksiklikler.md` dosyasında takip edilir. Tamamlanma durumu son doğrulama kaydıyla birlikte değerlendirilir.
- Uygulama SOLID prensiplerine uygun, sıfır `flutter analyze` hatasına sahip, tüm birim ve widget testlerinden (`flutter test`) geçen, tutarlı tasarımlı ve kalıcı yerel verilere sahip durumdadır.


## 7. Kesinti Sonrası Davranışlar — 25 Ekim 2026

Keşfet sonuçsuz kaldığında filtreleri ve arama kutusunu sıfırlayan boş durum kartı görünür. Rezervasyon kartları tarih aralığını gösterir; bakıcı paneli tüm onaylı konukları listeler. Ana sayfa seçili petId için gerçek başlangıç/bitiş saatini kullanır; aktif hizmeti, sıradaki onayı ve bekleyen/ek kayıt sayılarını ayırır. Aktif yürüyüş dışında takip aksiyonu sunulmaz. Sağlık özeti gecikmiş ve okunamayan kayıtları tamamlanmış saymaz. Onay, iptal ve profil değişiklikleri diğer sekmelere yansır.

Sohbet geçmişi kararlı sahip–bakıcı kimlik çiftine göre ayrılır ve rol değişiminde mesaj göndericisi korunur. Rezervasyon takvimi dolu günlerin üzerinden aralık seçilmesini engeller; eksik veya geçersiz tarihlerle gönderim kapatılır ve kayıt anında müsaitlik yeniden doğrulanır. Ücret birimleri ilana göre `gece`, `saat` veya `gün` olarak görünür. Bakıcı kazancı, ilgili ayda başlayan onaylı kayıtlardan hesaplanır; başlangıç toplamı sıfırdır.

`AppStrings` merkezi Türkçe metin kaynağıdır; başka dil paketleri veya çalışan bir dil seçici bu kapsamda eklenmemiştir. Hive ve yerel demo kapsamı korunmuştur. Son test ve analiz sonuçları [`yapilanlar.md`](../yapilanlar.md) içindedir.

### Önceki 21 maddelik denetimin sonucu

21/21 rapor maddesi tamamlandı; 61 test başarılı ve Flutter analizi temiz. Bakıcı profil adı doğru kalıcı ilanla eşitlenerek Home/Keşfet/panelde gösterilir. Farklı sahiplerin aynı bakıcıyla konuşmaları ayrılır; isim/e-posta değişikliği konuşma kimliğini değiştirmez. Aynı rol içindeki hesap geçişi kayıtları yeniler. Tüm veriler doğrudan saf, tip güvenli Hive modelleri üzerinden çalışır; geçici migrasyon ve legacy kodları projeden tamamen kaldırılmıştır (Sıfır Legacy & Sıfır Migrasyon Politikası).

## 8. Yeni denetim — Adım 1

İlk adım sonunda **6/50 tamamlandı, 44 açık**; 71 test başarılı ve analiz temiz. Köpek sahipliği ve aktif köpek seçimi hesaba bağlıdır; yeni sahip başka kişinin köpeğini görmez ve boş durumdan ekleme yapar. Bildirim alıcısı/rolü ve olay tarihi kalıcıdır. Her yeni bakıcının kendi kararlı kimliği ve yayınlanmamış ilan taslağı vardır; giriş bu hesabın rolünü ve ilanını geri yükler. İlan bilgileri tamamlanınca taslak kataloğa katılır. İlk kurulumdan sonraki bilinçli boş listeler yeniden demo veriyle doldurulmaz. Kod tabanında legacy adaptörleri veya ara geçiş sınıfları bulunmaz; doğrudan saf Hive modelleri geçerlidir.


<!-- audit-progress:start -->

**Yeni denetim güncel durumu: 47/50 tamamlandı, 3 kabul bekliyor. 171 VM testi başarılı; 3 Chrome senaryosu doğrulandı; Flutter analizi temiz.**

Android süreç yeniden oluşturma ve native profile performans kabulü tamamlandı. iOS/macOS kaynak ayarları hazır; bu Linux ortamında cihaz/sandbox kabulü yapılmadı. Yayın sertifikası ayrıca sağlanmalıdır.

Chrome önizleme başlangıcında Hive IndexedDB kullanılır; native fotoğraf kurtarma ve yetim dosya taraması webde çalıştırılmaz.

Ayrıntılı görev/kabul durumu: [eksiklikler.md](../eksiklikler.md).

<!-- audit-progress:end -->
