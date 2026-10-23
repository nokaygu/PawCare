# PawCare — Tasarım Sistemi ve Uygulama Tasarım Kuralları

## 1. Projenin Tanımı

**PawCare**, köpek sahiplerinin köpeklerinin profillerini ve sağlık kayıtlarını yönetebildiği, güvenilir köpek otellerini ve bakıcıları keşfedebildiği, gezdirme veya konaklama rezervasyonu oluşturabildiği bir Flutter mobil uygulamasıdır. Hizmet verenler de kendilerine gelen talepleri yönetebilir, rezervasyonları takip edebilir ve hizmet ilanlarını düzenleyebilir.

Uygulamanın hedefi yalnızca çalışan özellikler sunmak değildir. PawCare; sakin, güvenilir, sıcak, profesyonel ve görsel açıdan özenli bir ürün gibi hissettirmelidir.

**Tasarımın ana kaynağı Stitch'te oluşturulan mevcut PawCare tasarımlarıdır.** Bu dosya, mevcut tasarımların Flutter'a aktarılması ve tasarım bütünlüğü bozulmadan eksik etkileşimlerin tamamlanması için hazırlanmıştır.

## 2. Değiştirilemez Tasarım Kuralları

Bu bölümdeki kurallar bütün geliştirme süreci boyunca geçerlidir.

1. Stitch'te oluşturulmuş altı mevcut ekranın tasarımını koru. Bu ekranları yeniden yorumlama, basitleştirme veya kendi tasarımınla değiştirme.
2. Stitch'in gerçek ekran kodlarına ve görsellerine erişebiliyorsan önce bunları incele. Yalnızca ekran isimlerine veya bu dosyadaki metinsel açıklamalara dayanarak tasarım üretme.
3. Stitch'ten alınan HTML/CSS yapısını ve görsel varlıkları Flutter/Dart bileşenlerine dönüştür. HTML'yi Flutter uygulamasında WebView içinde çalıştırarak dönüşüm yapılmış gibi gösterme. Amaç yerel Flutter widget'larıyla gerçek bir mobil uygulama geliştirmektir.
4. Mevcut ekranlardaki yerleşimi, kart oranlarını, görsel boyutlarını, boşlukları, yazı hiyerarşisini, renkleri, köşe yuvarlaklıklarını, ikonları ve görsel yoğunluğu koru.
5. Yeni ekran, modal, form veya alt menü eklerken mevcut tasarım sisteminin dışına çıkma.
6. Mevcut ekranları yeniden tasarlamak yerine eksik işlevleri mevcut ekranların doğal akışına ekle.
7. Ekranları gereksiz yere sadeleştirme. Stitch'teki bilgi yoğunluğunu, görsel katmanları ve içerik sırasını koru.
8. Kendi tercihine göre yeni renk paleti, font, ikon ailesi veya bileşen stili oluşturma.
9. Bir ekranın tasarım ayrıntısı belirsizse önce mevcut Stitch ekranlarının kodunu, stillerini ve benzer bileşenlerini incele. Tahminle tasarım değiştirme.
10. Stitch kaynaklarına erişilemiyorsa mevcut tasarımlara sadık kalınmış gibi davranma. Erişilemeyen kaynakları ve eksik bilgileri açıkça belirt; ekranları kendi kafana göre yeniden üretme.
11. Hiçbir mevcut ekranın tasarımını, yalnızca yeni bir özelliği uygulamak daha kolay olsun diye değiştirme.
12. Tasarım sadakati ile kod kolaylığı çatışırsa öncelikle tasarım sadakatini koruyan bir Flutter çözümü geliştir.

**Kabul ölçütü:** Uygulama Chrome'da açıldığında mevcut Stitch ekranları, metinsel tariflere göre hazırlanmış yaklaşık benzerler değil, erişilebilen gerçek tasarımların mümkün olduğunca sadık Flutter karşılıkları olmalıdır.

## 3. Stitch Projesi ve Kaynaklar

- Proje adı: PawCare Pet Management App
- Stitch proje kimliği: `14749173260488136004`

Ekran kimlikleri:

1. `ea407f064aa340a1a136fbe6fafa4e07`
2. `0a344d5b6d0a41f5b65d7edd95086327`
3. `1e58aab8770a46e69d6abd395f45429e`
4. `2856aa86a0924d47bcb8fe2db05967b6`
5. `48aff906f7a8433aac80e72ea9b04de6`
6. `1931a1d370c94953a5f7445deea97806`

Stitch'in dışa aktarma talimatı:

- İlgili projenin ekranlarına ait görselleri ve kodları al.
- Barındırılan dosya bağlantılarından indirme gerekiyorsa yönlendirmeleri takip edebilen `curl -L` gibi bir araç kullanılabilir.
- İndirilen HTML, CSS, görseller ve diğer kaynakları incele.
- Görselleri mümkünse yerel Flutter varlıkları olarak kullan.
- Stitch'teki görsel kaynaklarını erişilebilir oldukları sürece yeniden kullan; yerlerine rastgele internet görselleri veya alakasız görseller koyma.

Bu kimlikler tek başına ekran kodu veya görsel URL'si değildir. MCP üzerinden gerçek kaynakların alınması gerekir.

## 4. Teknik Ortam ve Mimari Sınırlar

Bu proje Flutter ve Dart ile geliştirilen bir mobil uygulamadır. İlk görsel kontrolü Chrome üzerinde yapılacaktır.

Kullanılacak teknolojiler:

- Flutter ve Dart
- GoRouter: Sayfa geçişleri ve alt navigasyon
- Cubit: Ekran durumu ve kullanıcı etkileşimleri
- Hive: Köpek profilleri, aşı kayıtları, rezervasyonlar ve yerel olarak saklanması gereken yapılandırılmış veriler
- JSON: Örnek hizmet veren ve ilan verileri
- `table_calendar`: Takvim ve tarih aralığı seçimi
- `image_picker`: Cihazdan köpek fotoğrafı seçimi

Veri kaynakları:

- Hizmet verenlerin başlangıç verileri `assets/sitters.json` dosyasından yüklenebilir.
- Kullanıcının oluşturduğu veya değiştirdiği köpek profilleri, sağlık kayıtları ve rezervasyonlar Hive üzerinden yerel olarak saklanır.
- Demo modu, iki rolün tek cihazda denenmesini sağlar.
- Sahibin oluşturduğu rezervasyon, aynı yerel veri kaynağı üzerinden hizmet veren modunda gelen talep olarak görünür.
- Gerçek sunucu, çevrim içi senkronizasyon, gerçek ödeme veya gerçek zamanlı konum altyapısı bu projenin ilk sürümünde bulunmaz.

GoRouter ve Cubit kullanılması, tasarımın farklılaşmasına gerekçe değildir. Mimari ne olursa olsun görsel sonuç Stitch tasarımına sadık kalmalıdır.

## 5. Görsel Kimlik: Şefkatli Denge

Tasarımın karakteri **Modern Dokunsal Minimalizm** yaklaşımına dayanır.

Hedeflenen his:

- Sıcak ve güvenilir
- Doğal ve sakin
- Özenli ve profesyonel
- Editoryal ve çağdaş
- Katmanlı ama sade
- Kaliteli bir evcil hayvan bakım hizmeti hissi veren

Şunlardan kaçınılmalıdır:

- Çocuksu çizgi film görünümü
- Gereksiz pati ve kemik ikonları
- Aşırı sevimli veya oyuncak benzeri arayüzler
- Neon renkler
- Yoğun cam efekti ve ağır bulanıklık
- Her karta güçlü gölge verme
- Rastgele dekoratif şekiller
- Her yerde farklı renk ve köşe yuvarlaklığı kullanma
- Birbirinden kopuk, hazır şablonlardan birleştirilmiş ekranlar

## 6. Renk Sistemi ve Renk Çelişkilerinin Yönetimi

Stitch'in dışa aktardığı renk tokenları ve açıklama metni arasında bazı değer farkları vardır. Bu farkları tüm ekranları tek bir renge zorlayarak çözme.

Öncelik sırası:

1. Mevcut Stitch ekranlarının gerçek HTML/CSS kaynaklarında veya tasarım verilerinde tanımlı olan değerler.
2. Mevcut ekranlarda kullanılan bileşenlerin ve durumların gerçek renkleri.
3. Aşağıdaki tokenlar.
4. Token bulunmayan yeni bileşenlerde, görsel açıdan en yakın mevcut bileşenin rengi.

### 6.1. Stitch tokenlarında yer alan renkler

| Token | Renk |
|---|---|
| `surface` | `#FBF9F3` |
| `surface-dim` | `#DCDAD4` |
| `surface-bright` | `#FBF9F3` |
| `surface-container-lowest` | `#FFFFFF` |
| `surface-container-low` | `#F5F3ED` |
| `surface-container` | `#F0EEE8` |
| `surface-container-high` | `#EAE8E2` |
| `surface-container-highest` | `#E4E2DD` |
| `on-surface` | `#1B1C18` |
| `on-surface-variant` | `#434843` |
| `inverse-surface` | `#30312D` |
| `inverse-on-surface` | `#F3F1EB` |
| `outline` | `#737872` |
| `outline-variant` | `#C3C8C1` |
| `surface-tint` | `#506354` |
| `primary` | `#1E3023` |
| `on-primary` | `#FFFFFF` |
| `primary-container` | `#344638` |
| `on-primary-container` | `#9FB3A1` |
| `inverse-primary` | `#B7CCB9` |
| `secondary` | `#586156` |
| `on-secondary` | `#FFFFFF` |
| `secondary-container` | `#DCE5D7` |
| `on-secondary-container` | `#5E675C` |
| `tertiary` | `#3B2811` |
| `on-tertiary` | `#FFFFFF` |
| `tertiary-container` | `#533E25` |
| `on-tertiary-container` | `#C7A98A` |
| `error` | `#BA1A1A` |
| `on-error` | `#FFFFFF` |
| `error-container` | `#FFDAD6` |
| `on-error-container` | `#93000A` |
| `primary-fixed` | `#D3E8D5` |
| `primary-fixed-dim` | `#B7CCB9` |
| `on-primary-fixed` | `#0E1F13` |
| `on-primary-fixed-variant` | `#394B3D` |
| `secondary-fixed` | `#DCE5D7` |
| `secondary-fixed-dim` | `#C0C9BC` |
| `on-secondary-fixed` | `#161E15` |
| `on-secondary-fixed-variant` | `#41493F` |
| `tertiary-fixed` | `#FEDDBB` |
| `tertiary-fixed-dim` | `#E1C1A0` |
| `on-tertiary-fixed` | `#291804` |
| `on-tertiary-fixed-variant` | `#58432A` |
| `background` | `#FBF9F3` |
| `on-background` | `#1B1C18` |
| `surface-variant` | `#E4E2DD` |

### 6.2. Marka açıklamasında belirtilen renkler

Marka açıklamasında ayrıca şu değerler bulunuyor:

- Ana arka plan: `#F7F5EF`
- Birincil marka rengi: `#344638`
- İkincil yüzey: `#DCE5D7`
- Dekoratif vurgu: `#E9C9A8`
- İkincil görsel yüzey: `#E9DCD2`
- Metin: `#292F29`
- Yükseltilmiş yüzey: `#FFFFFF`

Bunlar mevcut Stitch ekranlarında kullanılıyorsa korunmalıdır. Gerçek ekran kaynakları incelenmeden bunları üstteki tokenlarla topluca değiştirme.

### 6.3. Renk kullanım kuralları

- Başlık ve ana metinler yüksek kontrastlı olmalıdır.
- Birincil butonlar mevcut tasarımda kullanılan koyu zeytin tonunu korumalıdır.
- Adaçayı yüzeyleri ikincil kartlar, filtreler ve bilgi alanları için kullanılabilir.
- Bej tonları dekoratif ve ikincil vurgularda kullanılabilir.
- Hata rengi yalnızca gerçek hata ve risk durumlarında kullanılmalıdır.
- Renkler rastgele çoğaltılmamalıdır.
- Metin ve arka plan kontrastı okunabilir olmalıdır.
- Aynı işlevi gören bileşenler tüm ekranlarda aynı renk kurallarını izlemelidir.

## 7. Tipografi

Ana yazı tipi **Nunito Sans** olmalıdır.

Türkçe karakterler eksiksiz desteklenmelidir: `ç, ğ, ı, İ, ö, ş, ü`.

Stitch kaynaklarında mevcut ekranlarda kullanılan gerçek boyutlar önceliklidir. Aşağıdaki değerler tasarım sistemi referanslarıdır.

| Stil | Boyut | Ağırlık | Satır yüksekliği |
|---|---:|---:|---:|
| Display | 36 px | 800 | 44 px |
| Headline Hero | 32 px | 700 | 40 px |
| Headline Screen | 26 px | 700 | 34 px |
| Headline Section | 19 px | 600 | 26 px |
| Title Card | 16 px | 600 | 22 px |
| Body Default | 14 px | 400 | 20 px |
| Body Medium | 14 px | 600 | 20 px |
| Caption | 12 px | 500 | 16 px |
| Label Tag | 11 px | 700 | 14 px |

Ek kurallar:

- Başlıkların boyutunu ekranlar arasında keyfî olarak değiştirme.
- Kart başlıklarını, fiyatları, açıklamaları ve yardımcı metinleri ayırt edilebilir bir hiyerarşide tut.
- Fiyatlar ve önemli metrikler tasarımdaki belirginliklerini korumalıdır.
- Metinleri kutulara sığdırmak için okunamayacak kadar küçültme.
- Türkçe metinlerde kesilme, harf bozulması ve anlamsız satır kırılması olmamalıdır.
- Metin ölçeklendirmesini ve erişilebilirliği dikkate al.

## 8. Boşluk, Izgara ve Yerleşim

- Temel boşluk sistemi 4 px katları üzerinden ilerler.
- Mobil yatay kenar boşluğu çoğunlukla 16–20 px aralığında tutulur.
- Küçük iç boşluk: 4–8 px.
- Standart bileşen boşluğu: 16 px.
- Bölüm aralığı: 24 px.
- Büyük bölüm geçişi: 32 px.
- Yatay kaydırılan kartların sonrasında doğal bir sağ kenar boşluğu bırak.
- Ekranın altındaki içerikler alt navigasyonun arkasında kalmamalıdır.
- Uzun ekranlar kaydırılabilir olmalıdır.
- Modal içerikleri ekrana sığmadığında modalın içeriği kaydırılmalıdır.
- Safe area ve klavye açıldığında form alanlarının görünür kalması dikkate alınmalıdır.

## 9. Kartlar, Köşeler ve Derinlik

### Köşe yarıçapları

- Küçük kontrol ve alanlar: 10–14 px.
- Standart kartlar: 18–22 px.
- Öne çıkan büyük kartlar: 24–30 px.
- Etiketler ve filtre çipleri: tam oval.

Mevcut Stitch bileşenlerinde farklı bir değer varsa o değer korunmalıdır.

### Derinlik

- Derinliği öncelikle yüzey renkleriyle oluştur.
- Standart kartlara gereksiz gölge verme.
- Beyaz yükseltilmiş kartlarda mevcut Stitch gölge stilini kullan.
- Modal pencereler arka plandan yeterince ayrışmalı, fakat ağır ve karanlık bir görünüm oluşturmamalıdır.
- Alt navigasyon ve öne çıkan aksiyonlar diğer yüzeylerden nazikçe ayrılmalıdır.

Stitch açıklamasındaki gölge referansları:

- Kart gölgesi: `0px 4px 20px -2px rgba(52, 70, 56, 0.05)`
- Yüzen eleman gölgesi: `0px 10px 30px -4px rgba(41, 47, 41, 0.08)`

Bu değerleri yalnızca görsel kaynaklarla uyumlu oldukları durumlarda uygula.

## 10. Butonlar ve Etkileşim Durumları

Her butonun işlevi ve görsel durumu tanımlanmalıdır.

### Birincil buton

- Koyu zeytin dolgu.
- Açık metin.
- Mevcut Stitch tasarımındaki yükseklik ve köşe yarıçapı.
- Yeterli dokunma alanı.

### İkincil buton

- Mevcut adaçayı veya açık yüzey rengi.
- Koyu metin.
- Birincil butonla uyumlu ölçüler.

### Hafif buton

- Gereksiz arka plan olmadan metin veya ikon.
- İptal, geri dönme ve ikincil eylemler için kullanılabilir.

### Etkileşim durumları

Bütün etkileşimli bileşenlerde uygun olduğu ölçüde şu durumlar tasarlanmalıdır:

- Normal
- Üzerine gelme (hover)
- Basılma (pressed)
- Odaklanma (focus)
- Devre dışı (disabled)
- Yüklenme (loading)
- Başarılı işlem
- Hata

Web/Chrome üzerinde hover desteği kullanılabilir. Mobil cihazlarda hover yerine basılma ve dokunsal geri bildirim kullanılmalıdır.

Stitch'teki butonlarda bulunan renk değişimi, hafif yukarı hareket ve yumuşak geçiş gibi ayrıntılar korunmalıdır. Hareketler küçük ve kontrollü olmalı; içerik yerleşimini bozacak sıçramalar kullanılmamalıdır.

Önerilen animasyon süreleri:

- Küçük geri bildirimler: 150–250 ms.
- Standart geçişler: 250–300 ms.
- Büyük geçişler: 350–400 ms.

Sürekli tekrarlanan, dikkat dağıtan animasyonlar kullanılmamalıdır. Animasyonlar işlevi açıklamalı ve kullanıcıyı yormamalıdır.

## 11. Formlar ve Arama Alanları

- Giriş alanlarının görünümü Stitch'teki gerçek alanlarla eşleşmelidir.
- Odaklanıldığında kenarlık ve durum değişimi görünür olmalıdır.
- Hatalar alanın yakınında anlaşılır Türkçe metinle gösterilmelidir.
- Zorunlu alanlar açıkça belirtilmelidir.
- Klavye açıldığında formun altındaki butonlar erişilebilir kalmalıdır.
- Şifre alanında göster/gizle kontrolü bulunmalıdır.
- Arama alanları yazılan metne göre gerçek filtreleme yapmalıdır.
- Filtreler seçildiğinde sonuç listesi güncellenmelidir.
- Sıfırlama butonu uygulanmış filtreleri temizlemelidir.
- Tarih aralığı, başlangıç ve bitiş kontrolüyle doğrulanmalıdır.

## 12. Mevcut Altı Stitch Ekranı

Aşağıdaki açıklamalar ekranların işlevlerini tarif eder. Görsel düzenin gerçek kaynağı Stitch ekranlarıdır; bu açıklamalar kullanılarak mevcut tasarımlar yeniden çizilmemelidir.

### Ekran 1 — Karşılama ve Demo Rolü Seçimi

İçerik:

- PawCare marka alanı ve karşılama mesajı.
- Köpek Sahibi demo seçeneği.
- Hizmet Veren demo seçeneği.
- Giriş Yap.
- Hesap Oluştur.

Davranış:

- Köpek Sahibi seçimi sahibin ana ekranını açar.
- Hizmet Veren seçimi hizmet veren panelini açar.
- Giriş Yap büyük bir giriş modalı açar.
- Hesap Oluştur büyük bir kayıt modalı açar.
- Demo seçimi gerçek hesap doğrulaması gerektirmez.
- Mevcut görsel düzen, metin hiyerarşisi ve buton yerleşimi korunur.

### Ekran 2 — Köpek Sahibi Hizmet Keşfetme

İçerik:

- Üst alanda Köpek Sahibi rol göstergesi.
- Bakıcı, otel veya gezdirici arama alanı.
- Konum ve fiyat filtreleri.
- Seçilen bölge için hizmet sayısı.
- Köpek Oteli, Köpek Gezdirme ve Gündüz Bakımı gibi kategoriler.
- Dikey hizmet ilanı kartları.
- İlan fotoğrafları, fiyatlar, puanlar ve ilgili bilgiler.
- İncele ve Talep Gönder eylemi.

Davranış:

- Arama ve filtreler sonuçları günceller.
- Kategori seçimi ilanları daraltır.
- Her ilan kartının inceleme eylemi doğru hizmetin detayını açar.
- Detay ve rezervasyon akışı, tasarımın yoğun içeriği gerektiriyorsa ayrı sayfa olarak açılabilir.
- Geri dönüşte seçilen filtreler mümkün olduğunca korunur.

### Ekran 3 — Köpek Sahibi Ana Sayfası

İçerik:

- Köpeğin fotoğrafı ve kısa profil bilgileri.
- Sağlık Kartı ve Profili Görüntüle eylemleri.
- Hizmet arama alanı.
- Popüler Hizmetler ve Tümünü Gör.
- Yaklaşan aşı uyarısı.
- Veteriner randevusu.
- Aşı Kartını Aç.
- Günün Rezervasyonu.
- Rezervasyon saatini gösteren canlı durum göstergesi.
- Hizmet verenin adı, puanı ve buluşma noktası.
- Canlı Takip ve sohbet eylemleri.
- Öne Çıkan Hizmetler ve Hepsi eylemi.

Davranış:

- Sağlık Kartı, sağlık kartı modalını açar.
- Profili Görüntüle, ilgili köpeğin profilini açar.
- Tümünü Gör, popüler hizmetlerin tamamını gösteren listeye geçer veya uygun bir tam liste görünümü açar.
- Aşı Kartını Aç, sağlık kartı modalını açar.
- Canlı Takip, demo harita modalını açar.
- Sohbet, mesajlaşma modalını açar.
- Hepsi, tüm öne çıkan hizmetlerin listesine gider.
- Rezervasyon durumu ve saatleri yerel rezervasyon verilerinden gösterilir.
- Yanıp sönen veya hareketli rezervasyon göstergesi mevcut Stitch tasarımındaki gibi korunur. Sürekli animasyonun erişilebilirlik seçeneği dikkate alınır.

### Ekran 4 — Hizmet Veren Detayı ve Rezervasyon

İçerik:

- Tesis fotoğraf galerisi.
- Hizmet verenin adı, unvanı ve tanıtımı.
- Adres, puanlar, yorumlar ve tesis olanakları.
- Rezervasyon yapılacak köpeğin seçimi.
- Tarih aralığı takvimi.
- Özel bakım ve beslenme notu.
- Gecelik/günlük/saatlik ücret bilgisi.
- Hizmet bedeli ve toplam tutar.
- Rezervasyon Talebi Gönder butonu.

Davranış:

- Takvimden seçilen tarihler görsel olarak işaretlenir.
- Bitiş tarihi başlangıç tarihinden önce olamaz.
- Ücret, hizmet türünün fiyat birimine göre hesaplanır.
- Toplam fiyat, tarih veya hizmet değiştiğinde güncellenir.
- Zorunlu alanlar eksikken talep gönderilmez.
- Talep gönderildiğinde rezervasyon Hive'a kaydedilir.
- Hizmet veren moduna geçildiğinde aynı talep gelen taleplerde görünür.
- İşlem sonrası başarı mesajı ve talep durumu gösterilir.
- Gerçek ödeme yapılmaz.

### Ekran 5 — Köpek Profili ve Sağlık Kartı

İçerik:

- Köpeğin fotoğrafı.
- Adı, ırkı, cinsiyeti, yaşı ve ağırlığı.
- Profil düzenleme.
- Yeni köpek ekleme.
- Kritik sağlık uyarısı.
- Aşı tarihi ve veteriner randevusu.
- Hatırlatıcı oluşturma.
- Aşı takvimi ve geçmiş kayıtlar.
- Yeni aşı/tedavi ekleme.
- Beslenme planı, alerjiler ve davranış notları.
- Veteriner kliniği iletişim alanı.
- Hemen Ara eylemi.

Davranış:

- Fotoğraf alanı cihazdan fotoğraf seçebilmelidir.
- Profil düzenleme formunda fotoğraf seçimi de bulunmalıdır.
- Yeni köpek ekleme, bağımsız bir köpek profili oluşturmalıdır.
- Aşı ekleme ve düzenleme işlemleri yerel veriye kaydedilmelidir.
- Hatırlatıcı butonu gerçek bir uygulama içi hatırlatıcı veya kayıtlı hatırlatma ayarı oluşturmalıdır. İşlem desteklenmiyorsa yapılmış gibi gösterilmemelidir.
- Aşı durumları tarihlere göre belirlenmelidir.
- Hemen Ara eylemi, cihaz destekliyorsa kayıtlı telefon numarasıyla arama başlatmak için kullanıcıya onay göstermelidir.
- Klinik telefon numarası demo verisiyse açıkça demo verisi olarak ele alınmalıdır.

### Hizmet Veren Paneli (ayrı bir girişi var)

İçerik:

- Hizmet veren adı ve profil alanı.
- Köpek Sahibi moduna geçiş.
- Bekleyen talepler sayısı.
- Onaylı rezervasyon sayısı.
- Kazanç özeti.
- Yeni gelen rezervasyon talebi.
- Köpek ve sahibinin bilgileri.
- Tarih, fiyat ve bakım notları.
- Reddet ve Onayla butonları.
- Mesaj Gönder ve Detayları İncele.
- Aktif ve yaklaşan konuklar.
- Sahibini Ara.
- İlanımı ve Fiyatlarımı Düzenle.
- Müsaitlik Takvimini Güncelle.
- Değerlendirmelerim.

Davranış:

- Onayla, rezervasyon durumunu Onaylandı olarak günceller.
- Reddet, onay penceresi açar ve onaylandıktan sonra durumu Reddedildi yapar.
- Her iki işlem de Hive'daki aynı rezervasyon kaydını günceller.
- Bekleyen ve onaylı sayıları güncel verilerden hesaplanır.
- Kazanç toplamı yalnızca tanımlı demo hesaplama kuralına göre gösterilir; uydurulmuş canlı finans verisi gibi sunulmaz.
- Detayları İncele, talep ayrıntısını açar.
- Mesaj Gönder, yerel demo sohbetini açar.
- İlan düzenleme, müsaitlik ve değerlendirmeler için alt navigasyon sekmeleri kullanılabilir.
- Rol değiştirme sahibin ana sayfasına geçer; uygulamanın tüm verileri aynı yerel kaynaktan okunur.

## 13. Modal ve Alt Sayfa Sistemi

PawCare'de her etkileşim için yeni bir tam ekran oluşturulması gerekmez. Küçük işlemler modal; uzun ve bağımsız akışlar ise ayrı sayfa olmalıdır.

Modal boyutu içerik miktarına göre belirlenmelidir. Her modal aynı yükseklikte olmamalıdır.

### 13.1. Büyük modal

Kullanım alanları:

- Giriş Yap
- Hesap Oluştur
- İlan inceleme ve rezervasyon talebi gerektiğinde

Görünüm:

- Ekranın büyük bölümünü kaplayan, ancak ekran sınırlarını aşmayan kart.
- Arka planda yarı saydam koyu katman ve yumuşak bulanıklık.
- Beyaz veya mevcut Stitch'teki yükseltilmiş yüzey rengi.
- Yuvarlatılmış köşeler.
- Üstte başlık ve kapatma düğmesi.
- İçerik uzunsa modal gövdesi kaydırılabilir.
- Sabit alt aksiyon alanı varsa klavye ve güvenli alanlarla çakışmamalıdır.

### 13.2. Orta boy modal

Kullanım alanları:

- Sağlık kartı.
- Aşı kartı.
- Sohbet.
- Canlı takip haritası.
- Tüm hizmetler veya kısa liste görünümü gerektiğinde.

İçerik kısa ise gereksiz boşluk bırakılmamalıdır. İçerik uzarsa kaydırma desteklenmelidir.

### 13.3. Küçük modal veya onay penceresi

Kullanım alanları:

- Rezervasyon reddetme onayı.
- Başarılı işlem mesajı.
- Fotoğraf seçimi için seçenekler.
- Arama başlatma onayı.
- Silme veya iptal işlemleri.
- Hatırlatıcı oluşturma onayı.

Kısa başlık, açıklama ve net eylemler içermelidir. Kullanıcı neyi onayladığını anlayabilmelidir.

### 13.4. Modal davranış kuralları

- Her modalın görünür bir kapatma düğmesi olmalıdır.
- Modal kapatıldığında arka plandaki ekranın durumu korunmalıdır.
- İçerik uzunsa yalnızca modal içeriği kaydırılmalıdır.
- Klavye açıldığında form alanları ve butonlar kullanılabilir kalmalıdır.
- Form kaydedilmeden kapatılmak üzereyse girilen verinin kaybolacağı durumlarda onay sorulmalıdır.
- Modal içindeki birincil buton gerçekten işlemi gerçekleştirmelidir.
- Modal açılma/kapanma animasyonu yumuşak ve kısa olmalıdır.
- Arka plan bulanıklığı tüm ekranı kapsamalı, modal içeriğini bulanıklaştırmamalıdır.
- Modal katmanları birbiriyle çakışmamalıdır.
- Gereksiz şekilde iç içe modal açılmamalıdır.

## 14. Giriş Yap Modalı

Giriş Yap butonuna basıldığında ayrı bir tam sayfaya gitmek yerine büyük bir modal açılır.

İçerik:

- Başlık: “Tekrar Hoş Geldin”
- Kısa açıklama: “PawCare hesabına giriş yap.”
- E-posta alanı
- Şifre alanı
- Şifreyi göster/gizle kontrolü
- “Giriş Yap” birincil butonu
- “Hesabın yok mu? Hesap Oluştur” bağlantısı
- Modalı kapatma düğmesi

Görünüm:

- Mevcut Nunito Sans ve PawCare renkleri.
- Beyaz/yükseltilmiş yüzey.
- Büyük ama dengeli iç boşluklar.
- Mevcut birincil buton stili.
- Arka planın bulanıklaştırılması.
- Küçük ekranlarda dikey kaydırma.

Davranış:

- Alanlar doğrulanır.
- Bu proje gerçek sunucu kimlik doğrulaması kullanmadığı için e-posta/şifre formu gerçek çevrim içi giriş gibi sunulmamalıdır.
- Yerel demo hesabı kullanılacaksa demo bilgileri açıkça belirtilmelidir.
- Alternatif olarak bu form, kullanıcıyı kayıtlı yerel demo profiline bağlayan bir akış olarak uygulanabilir.
- Başarılı demo girişinde uygun rolün ana ekranı açılır.
- Geçersiz alanlar için Türkçe hata mesajları gösterilir.

## 15. Hesap Oluştur Modalı

İçerik:

- Başlık: “PawCare'e Katıl”
- Ad soyad
- E-posta
- Şifre
- Şifre tekrar
- Rol seçimi: Köpek Sahibi / Hizmet Veren
- “Hesap Oluştur” birincil butonu
- “Zaten hesabın var mı? Giriş Yap” bağlantısı
- Kapatma düğmesi

Köpek sahibi seçildiğinde köpek bilgileri aynı formu aşırı uzatacak şekilde zorunlu tutulmamalıdır. Önce kullanıcı profili oluşturulur; ardından ilk köpeğini eklemek için isteğe bağlı bir adım sunulabilir.

Yerel demo kapsamında:

- Gerçek e-posta doğrulaması veya sunucu hesabı oluşturulduğu iddia edilmemelidir.
- Gerekli kullanıcı bilgileri yerel olarak saklanabilir.
- Köpek profili daha sonra eklenebilir.
- Hizmet veren rolü seçildiğinde gerekli hizmet profili daha sonra tamamlanabilir.
- Kayıt sonrası doğru rolün ana ekranı açılmalıdır.

## 16. Canlı Takip Modalı

Günün Rezervasyonu bölümündeki Canlı Takip eylemi orta/büyük bir modal açar.

İçerik:

- Buluşma noktası: örneğin Caddebostan Sahil Parkı.
- Basitleştirilmiş, anlaşılır harita alanı.
- Başlangıç/buluşma noktası işareti.
- Demo yürüyüş rotası gösterilecekse açıkça örnek rota olduğu anlaşılmalıdır.
- Yürüyüş süresi veya mesafe gibi demo değerleri yalnızca demo bilgisi olarak gösterilmelidir.
- Kapatma düğmesi.

Gerçek GPS, canlı konum paylaşımı veya harita sağlayıcısı entegrasyonu bulunmadığı için sahte canlı konum üretilmemelidir. Gerçek zamanlı konum varmış gibi bir animasyonla kullanıcı yanıltılmamalıdır.

## 17. Sohbet Modalı

Günün Rezervasyonu veya hizmet veren panelindeki Mesaj Gönder eylemi sohbet modalı açar.

İçerik:

- Karşı tarafın adı ve profil görseli.
- Mesaj listesi.
- Mesaj yazma alanı.
- Gönder butonu.
- Modalı kapatma düğmesi.

Davranış:

- Kullanıcı mesaj yazabilmelidir.
- Gönderilen mesaj sohbet ekranında görünmelidir.
- Demo sohbeti yerel olarak saklanabilir.
- Başka bir kullanıcıya internet üzerinden gerçek mesaj gönderildiği iddia edilmemelidir.
- Sohbet içeriği uzun olduğunda mesaj listesi kaydırılmalıdır.
- Gönder butonu boş mesajla çalışmamalıdır.

## 18. Sağlık Kartı Modalı

Ana sayfadaki Sağlık Kartı ve Aşı Kartını Aç eylemleri sağlık kartını açmalıdır.

İçerik:

- Köpeğin adı ve fotoğrafı.
- Yaklaşan aşı.
- Aşı tarihi.
- Aşı durumu.
- Sonraki uygulama tarihi.
- Veteriner randevusu.
- Aşı kayıtlarına gitme veya yeni aşı ekleme eylemi.

Bu modal, mevcut sağlık ekranının küçültülmüş ve uyarlanmış sürümü olmalıdır. Farklı bir tasarım dili kullanılmamalıdır.

İçerik küçük modal için fazla uzunsa orta boy kaydırılabilir modal kullanılmalıdır.

## 19. Telefon Arama Akışı

“Hemen Ara” ve “Sahibini Ara” eylemleri:

1. Kısa bir onay penceresi açar.
2. Aranacak kişi veya klinik adını ve telefon numarasını gösterir.
3. “Ara” ve “Vazgeç” seçeneklerini sunar.
4. Kullanıcı onaylarsa cihaz destekliyorsa telefon araması başlatılır.

Tarayıcı veya cihaz aramayı desteklemiyorsa kullanıcıya anlaşılır bir mesaj gösterilmelidir. Eylem başarılı olmuş gibi sahte bildirim gösterilmemelidir.

## 20. Köpek Fotoğrafı Seçme ve Profil Düzenleme

- Köpek fotoğrafı cihazdan seçilebilmelidir.
- Fotoğraf seçimi için `image_picker` kullanılmalıdır.
- İzin reddedildiğinde kullanıcıya açıklayıcı mesaj gösterilmelidir.
- Seçilen fotoğraf profil kartında ve ilgili sağlık ekranında güncellenmelidir.
- Kullanıcı fotoğrafı değiştirebilmelidir.
- İptal edilen seçim mevcut fotoğrafı bozmamalıdır.
- Fotoğrafın yerel saklama yöntemi ve dosya yolu platformla uyumlu olmalıdır.
- Fotoğraf bulunmadığında tasarımın bütünlüğünü koruyan bir varsayılan görsel kullanılabilir.

## 21. Alt Navigasyon

Alt navigasyon çubuğu her rol için farklı olmalıdır.

### Köpek Sahibi

1. Ana Sayfa
2. Keşfet
3. Köpeklerim
4. Taleplerim
5. Profil

### Hizmet Veren

1. Panel
2. İlanım
3. Takvim
4. Değerlendirmeler
5. Profil

Kurallar:

- Aktif sekme mevcut koyu zeytin rengiyle vurgulanmalıdır.
- İkon ve metin birlikte anlaşılır olmalıdır.
- Sekme değişimi yumuşak olmalıdır.
- Her sekme gerçek bir ekran veya işlevsel bir görünüm açmalıdır.
- Boş veya işlevsiz sekmeler oluşturulamaz.
- Rol değiştirildiğinde doğru rolün alt navigasyonu gösterilmelidir.
- Modal açıkken alt navigasyon yanlışlıkla etkileşime girmemelidir.
- Alt navigasyon mevcut Stitch ekranlarının yerleşimini bozmayacak şekilde uygulanmalıdır.

## 22. Rezervasyon ve Durum Takibi

Rezervasyon durumları en az şu değerleri desteklemelidir:

- Beklemede
- Onaylandı
- Reddedildi
- Tamamlandı

Davranış:

- Sahibin gönderdiği talep Beklemede durumuyla oluşturulur.
- Hizmet veren Onayla dediğinde aynı kayıt Onaylandı olur.
- Hizmet veren Reddet dediğinde onay sonrası aynı kayıt Reddedildi olur.
- Tamamlandı durumu yalnızca tanımlanmış bir tamamlama eylemiyle veya açık bir demo kuralıyla belirlenir.
- Sahibin Taleplerim ekranı ve hizmet verenin paneli aynı yerel kayıtları kullanır.
- Ekranlar arasında gidip gelindiğinde veriler birbiriyle tutarlı kalır.
- Fiyat, tarih aralığı, köpek ve hizmet veren bilgileri aynı rezervasyon kaydına bağlı olmalıdır.
- Rezervasyon verileri Hive'da saklanmalıdır.

## 23. Görsel Varlıklar ve Fotoğraflar

- Stitch'teki gerçek görseller öncelikle kullanılmalıdır.
- Dosyalar yerel varlık olarak ekleniyorsa yolları doğru yapılandırılmalıdır.
- Görsellerin yüklenememesi durumunda hata veya varsayılan görsel tasarım dilini korumalıdır.
- Her hizmet kartına aynı köpek fotoğrafını kopyalayıp yapıştırma.
- Gerçekçi ve farklı köpek/hizmet fotoğrafları kullanılmalıdır.
- İnternetten rastgele bağlantı oluşturma veya çalışmayan URL kullanma.
- Fotoğrafların kırpılması, oranı ve köşe yuvarlaklığı Stitch ile uyumlu olmalıdır.
- Fotoğraf seçimiyle yüklenen kullanıcı fotoğrafı ile sabit demo fotoğrafları birbirinden ayrılmalıdır.

## 24. İçerik ve Türkçe Metinler

- Kullanıcıya görünen tüm metinler Türkçe olmalıdır.
- Türkçe karakterler doğru yazılmalıdır.
- Buton isimleri kısa, açık ve tutarlı olmalıdır.
- Tarih ve fiyat biçimleri Türkiye kullanımına uygun olmalıdır.
- Fiyatlar Türk lirası biçiminde gösterilmelidir.
- Örnek kişi, köpek, hizmet ve rezervasyon verileri demo verisi olarak ele alınmalıdır.
- Gerçek kullanıcı yorumu, gerçek konum, gerçek kazanç veya gerçek veteriner verisi varmış gibi sunulmamalıdır.
- Sahte içerikler gerçek hizmet olarak tanıtılmamalıdır.

## 25. Erişilebilirlik ve Farklı Ekran Boyutları

- İlk hedef mobil telefon düzenidir.
- Chrome'da geliştirici araçlarıyla farklı ekran genişlikleri kontrol edilmelidir.
- İçerikler ekran dışına taşmamalıdır.
- Metinler ve butonlar kesilmemelidir.
- Klavye açıldığında formlar kullanılabilir kalmalıdır.
- Dokunma alanları rahat kullanılmalıdır.
- Renk tek başına durum belirtmek için kullanılmamalı; metin veya ikon desteği olmalıdır.
- Animasyonlar içeriğin okunmasını engellememelidir.
- Web/Chrome ve mobil platformların hover, dosya seçme ve telefon araması gibi davranışları farklı olabileceği için platforma uygun davranış sağlanmalıdır.

## 26. Hata, Boş Durum ve Yüklenme Görünümleri

Her veri listesi ve form için uygun durumlar tasarlanmalıdır:

- Yükleniyor
- Sonuç bulunamadı
- Henüz rezervasyon yok
- Henüz aşı kaydı yok
- Fotoğraf seçilmedi
- Veri kaydedilemedi
- Geçersiz form alanı
- İşlem başarılı

Bu durumlar mevcut renk ve tipografi sistemine uymalıdır. Teknik hata metinleri doğrudan kullanıcıya gösterilmemelidir.

## 27. Uygulama Kalitesi ve Tasarım Doğrulaması

Tasarım tamamlandı demek yalnızca uygulamanın açılması demek değildir.

Aşağıdaki kontroller yapılmalıdır:

1. Altı mevcut Stitch ekranının her biri Flutter karşılığıyla açılabilmelidir.
2. Stitch kaynaklarında bulunan gerçek görseller kullanılmalıdır.
3. Metin, kart, boşluk, renk ve tipografi mümkün olduğunca kaynakla eşleşmelidir.
4. Bütün butonlar ve etkileşimli alanlar çalışmalıdır.
5. Modallar açılmalı ve doğru şekilde kapanmalıdır.
6. Alt navigasyon doğru ekranlara gitmelidir.
7. Rol değiştirme iki yönlü çalışmalıdır.
8. Rezervasyon sahibin oluşturduğu kayıt olarak hizmet veren tarafında görünmelidir.
9. Hive verileri ekranlar arasında tutarlı kalmalıdır.
10. Arama, filtreleme, tarih seçimi ve fiyat hesabı çalışmalıdır.
11. `image_picker` akışı uygun platformda denenmelidir.
12. Chrome'da `flutter run -d chrome` ile uygulama açılabilmelidir.
13. `dart format` uygulanmalıdır.
14. `flutter analyze` hatasız tamamlanmalıdır.
15. Mümkün olan testler çalıştırılmalıdır.
16. Kaynaklara erişilemediği veya gerçek tasarım karşılaştırması yapılamadığı durumlar açıkça raporlanmalıdır.

## 28. Son İlke

PawCare için doğru sonuç, yalnızca benzer renklerle hazırlanmış yeni bir arayüz değildir.

**Hedef; Stitch'te tasarlanmış mevcut PawCare ekranlarını mümkün olduğunca sadık biçimde Flutter/Dart'a taşımak, eksik etkileşimleri aynı tasarım dilinde tamamlamak ve tüm temel işlevleri gerçekten çalışır hâle getirmektir.**

Tasarım sadakati, tutarlılık ve çalışan etkileşimler geliştirme boyunca birlikte korunmalıdır.