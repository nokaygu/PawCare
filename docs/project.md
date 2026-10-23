# PawCare — Proje Tanımı

## 1. Projenin amacı

PawCare, köpek sahiplerini köpek otelleri, günlük bakım hizmetleri ve köpek gezdiricileriyle buluşturan Flutter mobil uygulamasıdır. Kullanıcılar köpeklerinin profillerini ve sağlık bilgilerini yönetebilir, hizmetleri inceleyebilir ve rezervasyon talebi oluşturabilir. Hizmet verenler ilanlarını ve rezervasyon taleplerini yönetebilir.

Proje, Flutter/Dart ve yerel depolama kullanılarak geliştirilecektir. Harici backend veya sunucu geliştirilmeyecektir.

## 2. Kullanıcı rolleri

- **Köpek sahibi:** Köpeklerini ve sağlık bilgilerini yönetir, hizmet arar, rezervasyon oluşturur ve taleplerini takip eder.
- **Hizmet veren:** Hizmet ilanını, fiyatlarını, müsaitlik takvimini ve gelen rezervasyon taleplerini yönetir.

Roller farklı yetkilere ve uygun ekranlara sahip olmalıdır. Demo rol seçimiyle uygulama kolayca denenebilmelidir.

## 3. Temel özellikler

- Karşılama, giriş ve kayıt arayüzleri.
- Köpek profili, fotoğrafı, aşı kayıtları ve özel bakım notları.
- Otel, gündüz bakım ve gezdirme hizmetlerini arama, filtreleme ve inceleme.
- Tarih aralığı seçerek rezervasyon talebi oluşturma.
- Beklemede, onaylandı, reddedildi ve tamamlandı rezervasyon durumları.
- Hizmet veren paneli, ilan ve müsaitlik yönetimi.
- Profil ve bildirim arayüzleri.
- Splash ekranı ve açık/koyu tema.

## 4. Tasarım ilkeleri

- Stitch'te hazırlanmış mevcut tasarım, temel görsel referanstır.
- `design-system.md` dosyasındaki kurallar uygulanmalıdır.
- Uygulama sıcak, sade, modern ve güven veren bir görünüme sahip olmalıdır.
- Üstteki yeşil **“Ekranlar”** çubuğu kaldırılmalıdır. Ekranlar arası ana navigasyon için alt navigasyon kullanılmalıdır.
- Sağ üstte profil ve bildirim ikonları bulunmalıdır.
- Splash ekranında PawCare logosu, ölçülü bir parlama/yüklenme animasyonu ve altında “PawCare” yazısı yer almalıdır.
- Açık ve koyu tema desteklenmelidir. Koyu tema tamamen siyah değil, koyu yeşil/haki tonlarında olmalıdır.

## 5. Veri ve kapsam

- Hizmet verenlerin başlangıç verileri JSON varlık dosyalarından okunur.
- Kullanıcının oluşturduğu veya değiştirdiği veriler Hive ile yerel olarak saklanır.
- Rezervasyon talepleri aynı cihazdaki köpek sahibi ve hizmet veren görünümlerinde ortak veri üzerinden takip edilir.
- Bu proje gerçek bir sunucuya, çevrim içi kimlik doğrulamaya, gerçek zamanlı GPS takibine veya uzaktan bildirim altyapısına sahipmiş gibi davranmamalıdır.
- Gerçek entegrasyon gerektiren özellikler, uygulanmadıkları sürece demo olarak açıkça ele alınmalıdır.

## 6. Başarı ölçütü

Uygulama tutarlı tasarıma, çalışan sayfa geçişlerine, doğru rol akışlarına, kalıcı yerel verilere ve hatasız temel kullanım akışlarına sahip olmalıdır. Yeni özellik eklemek mevcut çalışan özellikleri bozmamalıdır.