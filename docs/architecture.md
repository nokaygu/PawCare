# PawCare — Mimari ve Klasör Yapısı

## 1. Mimari yaklaşım

**Feature-first + katmanlı yapı** kullanılacaktır. Her özellik kendi ekran, durum yönetimi ve bileşenlerini barındırır. UI, veri erişimini doğrudan yapmaz.

Veri akışı:

`View → Cubit → Repository → Local Data Source`

- **View:** Ekranı oluşturur, kullanıcı etkileşimlerini Cubit'e iletir.
- **Cubit:** Ekranın durumunu ve kullanıcı işlemlerini yönetir.
- **Repository:** Veriye erişimin arayüzünü ve iş kurallarını yönetir.
- **Data Source:** Hive veya JSON üzerinden veri okur/yazar.

Basit bir işlem için gereksiz katman, soyutlama veya dosya oluşturulmaz.

## 2. Hedef klasör yapısı

```text
lib/
  main.dart
  app/
    app.dart
    router/
      app_router.dart
      route_names.dart
  core/
    theme/
    constants/
    utils/
    widgets/
  data/
    local/
    repositories/
    models/
  features/
    onboarding/
      view/
      cubit/
      widgets/
    auth/
      view/
      cubit/
      widgets/
    home/
      view/
      cubit/
      widgets/
    discovery/
      view/
      cubit/
      widgets/
    pets/
      view/
      cubit/
      widgets/
    bookings/
      view/
      cubit/
      widgets/
    provider/
      view/
      cubit/
      widgets/
    profile/
      view/
      cubit/
      widgets/
    notifications/
      view/
      cubit/
      widgets/
    splash/
      view/
      cubit/
      widgets/
assets/
  images/
  data/
test/
```

Bu yapı hedef yapıdır; her özellik için kullanılmayan klasörler veya boş dosyalar oluşturulmaz. Mevcut proje dosyaları incelendikten sonra gerekli klasörler oluşturulur ve mevcut kod uygun yerlere taşınır. Model dosyaları, mevcut tasarıma ve veri akışına göre `data/models/` altında tutulabilir.

## 3. Katman sorumlulukları

- `main.dart`: Flutter başlangıcı, gerekli servislerin başlatılması ve uygulamanın çalıştırılması.
- `app/`: Uygulama kurulumu, tema bağlantısı ve GoRouter yapılandırması.
- `core/`: Temalar, sabitler, yardımcı araçlar ve özellikler arasında ortak kullanılan widget'lar.
- `data/`: Modeller, Hive kutuları, JSON kaynakları ve repository uygulamaları.
- `features/`: Kullanıcıya görünen özellikler; her özellik kendi View, Cubit ve gerektiğinde Widgets dosyalarını içerir.
- `assets/`: Yerel görseller, logo ve başlangıç verileri.
- `test/`: Model, Cubit, repository ve kritik kullanıcı akışı testleri.

## 4. Mimari kurallar

1. View katmanı Hive'a veya JSON dosyalarına doğrudan erişmez.
2. Birden fazla ekranın paylaştığı iş kuralları ilgili repository veya ortak servis içinde tutulur.
3. Widget'lar mümkün olduğunca küçük ve yeniden kullanılabilir olmalıdır.
4. Uygulama navigasyonu GoRouter üzerinden yönetilir.
5. Tema değişimi merkezi tema yapılandırması üzerinden yapılır.
6. Aynı veri için birden fazla bağımsız kaynak oluşturulmaz. Rezervasyon verisinin tek bir ortak kaynağı bulunur.
7. Mevcut dosyalar taşınırken import'lar, route'lar, asset yolları, testler ve bağımlılıklar birlikte güncellenir.
8. Dosyaları taşımak için mevcut kodu baştan yazmak yerine önce mevcut implementasyon korunur ve gerekli en küçük değişiklikler yapılır.

## 5. Mevcut kodun taşınması

Yeni mimari mevcut dosya ve klasörler incelenmeden uygulanmaz. Önce mevcut yapı ve bağımlılıklar çıkarılır; ardından dosyalar hedef yapıya aşamalı olarak taşınır. Her aşamada analiz ve test yapılır. Çalışan tasarım veya işlevler, yalnızca klasör yapısını değiştirmek amacıyla yeniden yazılmaz.