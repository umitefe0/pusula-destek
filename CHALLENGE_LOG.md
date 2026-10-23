# CHALLENGE_LOG

## Başlangıç noktası
- İlham kaynağı Zendesk; canlı ürün: https://pusula-destek.onrender.com
- Geçen haftanın son commit'i: [f5872db](https://github.com/umitefe0/pusula-destek/commit/f5872db5b10b85e238a08a6c7fbb0e37527e0926).
- Destek ekipleri talep atama, müşteriye yanıt, çözüm ve süre takibi için ödeme yapar. Fortune 500 satın alma kanıtı ve araştırma README'dedir.
- Başlangıçta ayrı iç not/dış yanıt formları ve imzalı önizleme vardı; metnin anlamı değerlendirilmiyordu.

## Acı
- Müşteri destek görevlisi yanlış kutuya ekip içi bilgi yazıp müşteriye gönderebilir. Meghann O., Customer Success Manager, 8 Eylül 2025, “Lots of functionality but difficult to navigate”: iç not yerine müşteriye yanıt göndermenin kolaylığı. [Capterra yorumları](https://www.capterra.com/p/164283/Zendesk/reviews/). Kaynak mevcut ürünün hiç koruması olmadığını ispatlamaz; kullanıcı deneyimindeki hata riskini gösterir.

## Bu haftanın vaadi
“Talep akışını, ayrı iç not formunu ve önizlemeyi çalışır hâle getirdim. Üzerine dış yanıt taslağının anlamını LLM ile kontrol eden bir koruma ekleyeceğim. Riskte gönder düğmesi görünmeyecek, ‘Emin misin?’ uyarısı ve gerekçe çıkacak. Taslak düzeltilebilecek veya iç nota alınabilecek. Kontrol tamamlanamazsa gönderilmeyecek.”

## Yapılanlar ve kanıt
- [Başlangıç vaadi commit'i](https://github.com/umitefe0/pusula-destek/commit/3597836).
- Groq structured JSON sınıflandırması, riskli/belirsiz içerikte gönder düğmesinin kaldırılması, düzeltme ve ekip içi nota kaydetme eklendi.
- Sunucu kontrolü aynı talep/görevli/metin ve 15 dakika koşulunu zorunlu kılıyor. API hatası, kota ve eksik anahtar gönderimi açmıyor.
- 23 Ekim yerel doğrulama: **52 test, 301 assertion, 0 failure/error/skip**. Zeitwerk ve assets derlemesi geçti. Testler gerçek API çağırmaz; sağlayıcı taklidi kullanılır.
- Yerel tarayıcıda eksik anahtar durumunda taslağın korunduğu ve gönder düğmesinin bulunmadığı görüldü.
- GitHub Actions ve canlı gerçek LLM kontrolü henüz bekliyor. Başarılı olduğu iddia edilmiyor.
- Demo adımları ve kod haritası: [ikinci hafta sunumu](docs/hafta-2-sunum.md).
- Yapılamayanlar: geniş kullanıcı deneyi/doğruluk ölçümü, RAG ve agent-first akış yok. Bunlar bu haftanın vaadi değildi. LLM kontrolü yüzde yüz sızıntı önleme değildir.

## Zaman
- İlk uygulama prompt'u (olduğu gibi): `tamam yapalım ödevi`
- Bundan önce öğretmenin ödev metni paylaşıldı ve kapsam konuşuldu.
- Agent zaman ölçüm kaydı başlangıcı: 23 Ekim 2026 13:38:47 Türkiye saati (10:38:47 UTC). Bu, ilk incelemenin birkaç dakika sonrasındaki ölçümdür; önceki süre ölçülmedi.
- İnsan zamanı: öğrenci henüz süre bildirmedi; bilinmiyor.
- Gerçek model token maliyeti ve aktif çalışma süresi sonuçta dürüstçe kaydedilecek. ChatGPT Plus öğrenci beyanı: aylık 20 USD; API erişimi bu aboneliğe dahil varsayılmaz.

## Karar
**Devam, daha dar odak:** Genel destek ürünü yerine dış yanıtta ekip içi bilgi sızıntısı riskini azaltmaya odaklanıyoruz. Mevcut talep akışı üzerinde bu kontrolü göstermek yeni bir ürün kurmaktan daha kısa doğrulama yolu. Destek yöneticisinin hatalı gönderim ve müşteri güven kaybını azaltmak için ödeme yapabileceği bir iş hipotezi var; müşteri görüşmesi veya ödeme ile henüz doğrulanmadı. LLM hata yapabilir; tam sızıntı önleme vaadi yoktur.
