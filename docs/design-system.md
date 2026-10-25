# PawCare — Tasarım Sistemi ve Merkezi Tema Kuralları (`design-system.md`)

## 1. Projenin Tanımı ve Stitch Sadakati

**PawCare**, sakin, güvenilir, sıcak ve profesyonel bir evcil hayvan bakım uygulamasıdır. Tasarımın ana kaynağı Stitch'te oluşturulan mevcut 6 PawCare ekranıdır (Proje Kimliği: `14749173260488136004`).

---

## 2. Değiştirilemez Tasarım ve Kodlama Kuralları

1. **Stitch Sadakati:** Mevcut 6 ekranın yerleşimini, kart oranlarını, boşluklarını, köşe yuvarlaklıklarını ve görsel yoğunluğunu koru.
2. **EKRAN DOSYALARINDA METİN, RENK, FONT KALINLIĞI VE SAYISAL BOYUT YASAĞI (KIRMIZI ÇİZGİ):**
   - Ekranların veya widget'ların içinde doğrudan kullanıcı metni (`Text('...')`), `Color(0xFF...)`, `Colors.white`, `FontWeight.bold`, `FontWeight.w600`, `fontSize: 14` veya sayısal `padding`/`margin`/`radius`/`width`/`height` gibi satır içi tanımlamalar **KESİNLİKLE YASAKTIR**.
   - Bu dokümandaki tüm renk tokenları `lib/core/theme/app_colors.dart` içinde, tüm yazı stilleri ve kalınlıkları `lib/core/theme/app_typography.dart` içinde, tüm ölçüler `lib/core/constants/app_dimens.dart` içinde ve tüm metinler `lib/core/constants/app_strings.dart` (`AppStrings`) içinde tanımlanmıştır.
   - Ekranlar yalnızca `Theme.of(context).colorScheme`, `Theme.of(context).textTheme`, `PawThemeExtension`, `AppDimens` ve `AppStrings` üzerinden bu değerleri okur.
3. **Saf Flutter Bileşenleri:** Harici takvim paketi (`table_calendar` vb.) kullanılmadan, bu tasarım sistemindeki köşe yuvarlaklıkları ve zeytin/adaçayı renkleriyle birebir uyumlu kendi `PawDateRangeCalendar` bileşenimiz `lib/core/widgets/` altında geliştirilmiştir.

---

## 3. Merkezi Renk Sistemi (`lib/core/theme/app_colors.dart`)

Aşağıdaki renkler **yalnızca** `app_colors.dart` ve `app_theme.dart` içinde tanımlanabilir:

### 3.1. Açık Tema (Stitch Orijinal Palet)
| Token | Hex | Kullanım |
|---|---|---|
| `surface` / `background` | `#FBF9F3` / `#F7F5EF` | Ana sayfa arka planı |
| `surfaceContainerLowest` | `#FFFFFF` | Yükseltilmiş kart ve modal yüzeyi |
| `surfaceContainerLow` | `#F5F3ED` | Yumuşak alt yüzey |
| `surfaceContainer` | `#F0EEE8` | Standart konteyner |
| `surfaceContainerHigh` | `#EAE8E2` | Vurgulu konteyner |
| `onSurface` | `#1B1C18` / `#292F29` | Ana başlık ve birincil metin |
| `onSurfaceVariant` | `#434843` | İkincil açıklama metni |
| `primary` | `#1E3023` / `#344638` | Birincil koyu zeytin marka rengi |
| `onPrimary` | `#FFFFFF` | Birincil buton metni |
| `secondary` | `#586156` | İkincil zeytin tonu |
| `secondaryContainer` | `#DCE5D7` | Adaçayı kart, çip ve etiket yüzeyi |
| `onSecondaryContainer` | `#394B3D` | Adaçayı yüzey üzerindeki metin |
| `tertiaryContainer` | `#E9C9A8` / `#E9DCD2` | Sıcak bej dekoratif vurgu yüzeyi |
| `outline` | `#737872` | Odaklanmış kenarlık |
| `outlineVariant` | `#C3C8C1` | İnce kart ve input kenarlığı |
| `error` / `errorContainer` | `#BA1A1A` / `#FFDAD6` | Hata ve reddedilme durumu |

### 3.2. Koyu Tema (Haki / Koyu Yeşil Dark Mode - Saf Siyah `#000000` Yasaktır!)
| Token | Hex | Kullanım |
|---|---|---|
| `background` | `#16241A` | Derin orman/haki arka plan |
| `surface` | `#1E3023` | Birincil koyu zeytin yüzey |
| `surfaceContainer` | `#243628` | Koyu tema kart yüzeyi |
| `surfaceContainerHigh` | `#344638` | Yükseltilmiş kart / modal yüzeyi |
| `primary` | `#DCE5D7` | Koyu temada ana vurgu (Açık Adaçayı) |
| `onPrimary` | `#16241A` | Birincil buton üzerindeki koyu metin |
| `onSurface` | `#EAE8E2` | Koyu temada ana okunabilir açık metin |
| `onSurfaceVariant` | `#9FB3A1` | Koyu temada ikincil metin |
| `outlineVariant` | `#394B3D` | Koyu tema kenarlık |

---

## 4. Merkezi Tipografi (`lib/core/theme/app_typography.dart`)

Ana yazı tipi **Nunito Sans**'tır. Hiçbir ekranda doğrudan `FontWeight` veya `fontSize` verilmez; tüm ekranlar aşağıdaki merkezi stilleri kullanır:

| Stil Adı (`TextTheme` Karşılığı) | Boyut | Ağırlık (`FontWeight`) | Satır Yüksekliği |
|---|---:|---:|---:|
| `displayLarge` (Display) | 36 px | `w800` | 44 px |
| `displayMedium` (Headline Hero) | 32 px | `w700` | 40 px |
| `headlineMedium` (Headline Screen) | 26 px | `w700` | 34 px |
| `titleLarge` (Headline Section) | 19 px | `w600` | 26 px |
| `titleMedium` (Title Card) | 16 px | `w600` | 22 px |
| `bodyMedium` (Body Default) | 14 px | `w400` | 20 px |
| `bodyLarge` (Body Medium) | 14 px | `w600` | 20 px |
| `bodySmall` (Caption) | 12 px | `w500` | 16 px |
| `labelSmall` (Label Tag) | 11 px | `w700` | 14 px |

---

## 5. Boşluk, Kartlar, Modallar ve Alt Navigasyon (`lib/core/constants/app_dimens.dart`)

- **Boşluk Sistemi:** `AppDimens` üzerinden 4 px katları (Mobil kenar boşluğu: `paddingMd` / `paddingLg`, kart içi: `p16`, bölümler arası: `p24`).
- **Köşe Yarıçapları:** Küçük alanlar `radiusSm`–`radiusMd`, standart kartlar `cardRadius` (`18.0`), büyük hero kartlar `radiusXl` (`24.0`), etiket/çipler tam oval (`radiusPill` / `StadiumBorder`).
- **Üst Bar:** Geçici yeşil "Ekranlar" çubuğu ve mükerrer profil ikonu kaldırılmıştır; sağ üstte okunmamış rozetli Bildirim ikonu (`PawHeaderActions`) yer alır.
- **Alt Navigasyon (5 Sekme — `PawBottomNav`):**
  - *Köpek Sahibi:* 1. Ana Sayfa, 2. Keşfet, 3. Köpeklerim, 4. Taleplerim, 5. Profil.
  - *Hizmet Veren:* 1. Panel, 2. İlanım, 3. Takvim, 4. Değerlendirmeler, 5. Profil.
- **6 Ana Ekran ve Etkileşimli Modallar:**
  - Ana Ekranlar: Karşılama, Keşfet, Sahip Ana Sayfası, Hizmet Detay & Rezervasyon, Çoklu Köpek Profili & Sağlık Kartı, Hizmet Veren Paneli ve Profil.
  - Modallar: Giriş (`LoginModal`), Kayıt (`SignupModal`), Sağlık Kartı (`HealthCardModal`), Köpek Profili Düzenleme (`EditDogProfileModal`), Yeni Köpek Ekleme (`AddDogModal`), Dijital Mikroçip Kimliği (`MicrochipIdentityModal`), Keşfet Filtreleme (`DiscoveryFilterModal`), İlan Düzenleme (`_EditSitterListingModal`), Kullanıcı Profili Düzenleme (`EditUserProfileModal`), Profil Bilgi Modalları (`ProfileInfoModal`), Yürüyüş Takip Demosu (`LiveTrackingModal`), Sohbet (`ChatModal`) ve Arama Onayı (`CallModal`).


## 6. Boş Durumlar ve Güncel Etkileşim Kuralları — 25 Ekim 2026

- Keşfet: eşleşme yoksa açıklama ve **Filtreleri Temizle** aksiyonu gösterilir; arama alanı da sıfırlanır.
- Ana sayfa: bugüne ait onaylı kayıt yoksa **Hizmetleri Keşfet** kartı gösterilir. Rezervasyon kartı gerçek hizmeti ve tarihleri kullanır; yalnız aktif kart rozeti kendi yaşam döngüsünde animasyon çalıştırır.
- Bakıcı paneli: bütün onaylı konuklar ayrı kartlarla gösterilir; liste boşsa açıklayıcı bir boş durum görünür.
- Taleplerim: kartlarda merkezi Türkçe tarih biçimi kullanılır; uzun ad ve ücretler dar ekranda taşmaz, aksiyonlar satıra sığmadığında alta geçer.
- İlan ve düzenleme formu ücret birimini `sitter.unitLabel` üzerinden gösterir.
- Dolu günleri kapsayan veya eksik tarih aralığıyla rezervasyon gönderilemez. Takvim bugünün ayıyla açılır.
- Klavye kullanılan sohbet, giriş ve kayıt modalları yarı saydam modal bariyerini kullanır; tam ekran bulanıklık hesaplanmaz.

Bu eklemeler mevcut tema, tipografi, ölçü ve merkezi metin kurallarıyla uygulanır. Denetim ve test sonuçları [`yapilanlar.md`](../yapilanlar.md) içindedir.


## 7. Profil ve Sohbet Tutarlılığı

Bakıcı profil adı kaydedildiğinde Home/Keşfet/panelde ilgili ilan adı güncellenir. Sohbet başlığındaki ad yalnız sunum içindir; konuşma sahip–bakıcı kimlik çiftiyle açılır. Hesap değişiminde başka kişiye ait geçmiş gösterilmez ve eski taslak temizlenir. Başka yerel hesaba atanmış e-posta profil düzenlemesinde kullanılırsa merkezi hata metni gösterilir ve form açık kalır. Bu akışlar mevcut görsel sistemi korur; 61 testlik doğrulama kapsamına dahildir.

## 8. Hesaba ait boş durumlar — Yeni denetim Adım 1

Yeni sahipte ana sayfa, Köpeklerim ve rezervasyon pet seçicisi `EmptyPetsCard` ile ilk köpek ekleme aksiyonu sunar; başka hesabın görsel/sağlık bilgisi örnek olarak yerleştirilmez. Pet yokken rezervasyon gönderimi kapalıdır. Ana sayfa karşılama metni koşulsuz sağlık garantisi vermeyen tarafsız bakım özeti kullanır. Bildirimler doğru alıcı/rol için gösterilir; zaman etiketi saklanmış tarihten üretilir, tarihi bilinmeyen demo kayıt açıkça etiketlenir. Mevcut renk/ölçü/tema sistemi korunur. Yeni kapsam: 6/50 madde, 71 başarılı test.


<!-- audit-progress:start -->

**Yeni denetim güncel durumu: 47/50 tamamlandı, 3 kabul bekliyor. 171 VM testi başarılı; 3 Chrome senaryosu doğrulandı; Flutter analizi temiz.**

Tasarım değiştirilmeden tembel listeler ve sınırlı decode doğrulandı. 1.000 kayıtta ilk bağlı kart sayısı Keşfet 2 / Taleplerim 5; native profile frame ve fotoğraf cache ölçümleri Adım 11 içindedir.

Chrome açılış düzeltmesinde tasarım değişmedi; gerçek WelcomeScreen ve OwnerHomeScreen görüntülenmesi doğrulandı.

Ayrıntılı görev/kabul durumu: [eksiklikler.md](../eksiklikler.md).

<!-- audit-progress:end -->
