# Canlı sunum provası

Canlı adres: https://pusula-destek.onrender.com
Repo: https://github.com/umitefe0/pusula-destek

## Sunumdan önce
- Siteyi birkaç dakika önce aç: ücretsiz servis uykudan uyanabilir.
- Müşteri demosunu seç. Aynı tarayıcı oturumunda rol değiştirmek kayıtları korur.
- Gerçek kişi/veri kullanma; örnek isimler ve mesajlar yeterli.
- GitHub Actions'taki son çalıştırmanın yeşil olduğunu kontrol et.

## Beş dakika
1. **30 saniye:** “Pusula Destek, şirketin müşteri taleplerini toplama, görevliye atama, yanıtlama ve çözme ihtiyacını karşılıyor. Kurumsal müşteri ve satın alma kanıtı README'de.”
2. **2 dakika:** Müşteri olarak “Siparişimde eksik ürün var” talebi aç. Görevliye geç, talebi üstlen. “Depoyla kontrol edilecek” iç notunu yaz. Müşteriye yanıt yaz, önizlemede alıcıyı göster, gönder. Müşteriye geç; iç not görünmez, yanıt görünür. Müşteri yanıtı gönder. Görevli olarak çöz. Müşteri ekranında Çözülenler filtresinden talebi bulup yeniden aç.
3. **1 dakika:** Modelde süre sabitlerini ve durum geçiş tablosunu; serviste resolve! metodunu; testte tam sınır anını göster.
4. **1 dakika:** README'deki yorum sahibini, yorum tarihini ve acısını söyle. Ayrı iç not alanı ve zorunlu önizlemeyi çözüm olarak göster. Gerçek e-posta ve gerçek hesap girişinin bulunmadığını belirt.
5. **30 saniye:** Hocanın kural değişikliği için aşağıdaki kod haritasını kullan.

## Kod haritası
| Değişiklik | Dosya | Aranacak ifade |
|---|---|---|
| İlk yanıt kaç saat? | app/models/ticket.rb | FIRST_RESPONSE_WINDOW |
| Son tarih nerede atanıyor? | app/controllers/tickets_controller.rb | first_response_due_at = |
| Üç gün bekleme | app/models/ticket.rb | FOLLOW_UP_WINDOW / follow_up_due? |
| Yeniden açma süresi | app/models/ticket.rb | REOPEN_WINDOW / reopenable? |
| Hangi durumdan hangisine geçilir? | app/models/ticket.rb | TRANSITIONS |
| Çözmeden önce yanıt zorunluluğu | app/services/ticket_workflow.rb | def resolve! |
| İç not müşteriden nasıl gizleniyor? | app/controllers/tickets_controller.rb | def show / visibility: :public_reply |
| Önizleme geçerliliği | app/controllers/tickets_controller.rb | expires_in |
| Tam sınır testleri | test/models/ticket_test.rb | with_usec: true |

“Hafta sonu SLA'ya sayılmasın” için sadece saat sabitini değiştirmek yetmez. İş günü takvimine göre son tarih hesaplayan ortak metot gerekir. Yeni talep oluşturma ve örnek veri servisi bunu çağırmalı; cuma akşamı, cumartesi ve pazartesi sınırları test edilmeli.

## Temel Ruby/Rails açıklamaları
- Model veri ve kuralları temsil eder; Ticket bir destek talebidir.
- Controller HTTP isteğini alır, izinleri denetler, servisi çağırır.
- View ekrana çıkan HTML'dir; ERB Ruby değerlerini HTML'e yerleştirir.
- TicketWorkflow bir işi tek transaction içinde tamamlar: hata olursa yarım mesaj/durum kalmaz.
- travel_to gerçek saati beklemeden testin saatini belirli ana taşır.
- PostgreSQL canlı veritabanıdır. GitHub kodları ve CI sonuçlarını; Render çalışan uygulamayı barındırır.
