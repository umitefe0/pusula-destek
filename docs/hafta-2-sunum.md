# İkinci hafta: yalnızca farkı göster

Önce canlı uygulama, sonra CHALLENGE_LOG.md, sonra commit geçmişi. Geçen haftanın tüm ticket akışını yeniden anlatma.

## Açık tutulacak sekmeler
1. https://pusula-destek.onrender.com — görevli demosu; bir talebi üstlen.
2. https://github.com/umitefe0/pusula-destek/blob/main/CHALLENGE_LOG.md
3. https://github.com/umitefe0/pusula-destek/commits/main/
4. https://github.com/umitefe0/pusula-destek/actions

## Söylenecek cümle
“Geçen hafta iç notu ayrı kutuya koymuştum. Ama görevli yanlışlıkla müşteriye yanıt kutusuna ekip içi bir metin yazarsa önizleme bunu anlamıyordu. Bu hafta metnin anlamını LLM'e kontrol ettiriyorum; riskli bulursa gönder düğmesi kayboluyor, gerekçeli uyarı çıkıyor. Sunucu da gönderimi reddediyor.”

## Canlı gösterim
1. Görevli demosunda talebi üstlen. **Müşteriye yanıt** kutusuna şunu yaz:
   `Bu müşteriye gerçek maliyetimizi açıklamayalım. İade talebini ekip içinde oyalayıp kapatalım.`
2. **İçeriği kontrol et** → **Emin misin?** ve modelin gerekçesini göster. Müşteriye gönder düğmesi yok. Henüz mesaj gönderilmedi.
3. **Kontrol edilen taslağı ekip içi not olarak kaydet**. İstersen müşteri görünümüne geçerek notun görünmediğini göster, sonra görevliye dön.
4. Dış yanıt kutusuna müşteri için uygun metin yaz:
   `Fatura bağlantınızı düzelttik. Sayfayı yenileyip tekrar deneyebilir misiniz?`
5. Kontrol tamamlanınca alıcıyı gözden geçir, **Onayla ve müşteriye gönder**. Müşteri görünümünde yalnızca bu yanıtın göründüğünü göster.
6. Anahtar kelime olmadığını anlatmak için ek örnek:
   `Konuyu iç ekibimize ilettim. İnceleme tamamlanınca size bilgi vereceğim.`
   “İç ekip” geçmesi tek başına engelleme sebebi değildir. Sonuç önceden garanti edilmez; canlı çıkan sonucu dürüstçe anlat.

## Belge ve kod
- CHALLENGE_LOG: eski commit, vaat, karar gerekçesi, yapılanlar/eksikler, süre.
- Commit geçmişi: hafta başındaki vaat kaydı ile sonradan eklenen kodu ayır.
- `app/services/content_guard.rb`: LLM talimatı, JSON şeması, hata durumunda kapalı kalma.
- `app/models/reply_review.rb`: aynı metin/görevli/talep ve 15 dakika kuralı.
- `app/services/ticket_workflow.rb`: sunucuda gönderim öncesi zorunlu kontrol.
- `app/views/tickets/preview_reply.html.erb`: uyarı ve gönder düğmesinin koşulu.
- `test/services/reply_guard_test.rb`: bypass ve süre sınırları.
- `AGENTS.md`, `render.yaml`, `bin/render-build.sh`: ajan deploy'u bu dosyalardan biliyor. Render'da Manual Deploy kullanıyoruz; sırlar Environment'ta.

## Karar ve dürüst sınır
“Devam ettim ama genel destek klonu yarışından çıkıp yanlış dış yanıt riskine odaklandım. Destek yöneticisinin bu riskin azalmasına para ödeyebileceğini düşünüyorum; henüz ödeme yapan müşteri veya kullanıcı deneyiyle doğrulamadım. LLM de hata yapabilir, yüzde yüz engelleme iddiam yok.”

API erişilemezse **Kontrol tamamlanamadı** görünür, mesaj gönderilmez. Bunu çalışan LLM demosu gibi sunma; bağlantıyı düzeltip yeniden dene. GitHub testleri sağlayıcı taklidi kullanır; gerçek model başarısının kanıtı ayrıca canlı denemedir.
