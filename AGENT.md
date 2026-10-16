# Pusula Destek — ortak çalışma sözleşmesi

Bu dosya öğrenci ve ajan arasındaki çalışma kurallarını kaydeder. Öğrencinin kabul ettiği kapsam: Rails 8+, canlı destek talebi akışı, Render, gerçek yorumdan gelen iç not/yanıt ayrımı. Bu ilk sürümdür; çalışmanın sonunda değişiklik kaydı tutulur.

## Sözlük
Talep = Ticket; müşteri = customer; görevli = agent; iç not = internal; müşteriye yanıt = public_reply; ilk yanıt süresi = first_response_due_at; müşteri bekleme = pending.

## İş kuralları
- Yeni → İşlemde → Müşteri bekleniyor → Çözüldü. Müşteri yanıtı bekleyen talebi işlemde durumuna döndürür.
- İlk yanıt hedefi 4 takvim saati. İç not ve müşteri mesajı ilk yanıt değildir.
- Müşteri yanıtı 3 gün beklenirse takip gerekir. Çözümden sonraki 7 gün dolmadan yeniden açılabilir.
- Her zaman sınırının öncesi/eşiti/sonrası `travel_to` ile test edilir. Her yasak geçiş testlidir.
- İç not ve dış yanıt farklı endpoint, form ve görünürlük filtresine sahiptir. Dış yanıt imzalı önizleme üzerinden gönderilir.
- Kayıtlar çalışma alanına, müşteri ekranı ayrıca müşteriye göre sınırlandırılır.

## Kod ve doğrulama
- İşlemler `TicketWorkflow` içinde açık metotlar, transaction ve satır kilidi ile yapılır.
- `default_scope`, `method_missing`, global monkey patch ve iş mantığı içeren callback yok.
- Model validasyonları servis dışından yapılan geçersiz durum değişikliklerini de reddeder.
- Çalıştırılmamış test için 'geçti' denmez. Yerel sonuç, GitHub Actions ve canlı kontrol ayrı ayrı raporlanır.
- Gerçek kullanıcı verisi, kart, parola ve API anahtarı depoya yazılmaz.
- Müşteri yorumundaki acı kaynakla kaydedilir; orijinalde bir özellik yoksa ancak kanıtla söylenir.
- G1–G5 tanımları sağlanmadı. Kendimiz ürettiğimiz belgeleri öğretmenin resmî G1–G5'i olarak sunmayız.

## Bilinçli mimari tercihler
- Minimal Rails kurulumu: Railties, Active Record, Action Pack/View. Mailer, Cable, Active Job kullanılmıyor; gereksiz yerel derleme ve servis bağımlılıkları eklenmez.
- Canlıda PostgreSQL + Puma; geliştirme/testte SQLite, Windows önizlemesinde WEBrick.
- Bu sürüm oturum başına yalıtılmış bir demo. Gerçek hesap/parola/SSO ve e-posta teslimatı yok. Müşteri yanıtı portalda görünür.
- Zaman uyarıları sayfa yenilendiğinde hesaplanır; arka plan bildirimi varmış gibi sunulmaz.

## 17 Ekim doğrulama sonrası değişiklikler
- Tam sınır testlerinde travel_to'nun mikrosaniyeyi silmesine karşı with_usec: true kullanılır.
- Ruby'nin Windows'taki Türkçe dizin sorununda yerel ASCII sürücü takma adı kullanılabilir; bu makineye özel yol repoya konmaz.
- Bağımlılık kilidi Windows ve Linux platformlarını içerir.
- Gerçek harcama/token sayısı ölçülmediyse bilinmiyor yazılır; tahmin gerçek maliyet diye gösterilmez.
