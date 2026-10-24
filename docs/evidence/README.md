# Gerçek canlı kontrol kanıtları

- 23 Ekim: `live-blocked.png` ilk riskli örnek; `live-customer.png` uygun yanıtın müşteriye görünmesi ve iç notun görünmemesi. Sürüm 0b72ce1.
- 24 Ekim: `live-evaluation-before-calibration.json` sürüm 06d3216 üzerindeki ilk iki sonuç; ikinci örnek YANLIŞ engellendi. Başarısızlık saklanmadı.
- 24 Ekim: `live-evaluation-final.json` sürüm 7a4f7bc üzerinde 8 gerçek Groq isteğinin tarayıcıdan okunan sonuçları. 4 safe, 4 blocked; tümü beklenen sınıfta.
- `live-blocked-final.png`, `live-safe-final.png`, `live-sent-final.png`: son sürümde riskli taslak, düzeltilmiş taslak için yeni onay ve gönderim.
- `live-blocked-preview.png`: aynı engellemenin ekrana sığan görüntüsü.

Bütün kişi ve mesajlar sentetik demo verisidir. Ekranlar gerçek uygulamadan alınmıştır, tasarım maketi değildir. JSON kayıtları tarayıcıdaki görünür sonuçlardan oluşturuldu; sunucu imzalı denetim kaydı değildir. Birkaç örnekle geniş doğruluk veya yüzde yüz koruma iddiası yapılmaz. CI'daki sağlayıcı taklitleri bu canlı sonuçlara karıştırılmaz.
