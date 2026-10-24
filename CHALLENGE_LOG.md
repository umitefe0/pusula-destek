# CHALLENGE_LOG

## Başlangıç noktası
- İlham kaynağı Zendesk; canlı ürün: https://pusula-destek.onrender.com
- Geçen haftanın son commit'i: [f5872db](https://github.com/umitefe0/pusula-destek/commit/f5872db5b10b85e238a08a6c7fbb0e37527e0926).
- Destek ekipleri talep atama, müşteriye yanıt, çözüm ve süre takibi için ödeme yapar. Örnek: [Stanley Black & Decker satın alma hikâyesi](https://www.zendesk.com.mx/customer/stanley-black-decker/); farklı kanallardan gelen talepleri tek yerde hızlı yönetmek. Fortune 500 kanıtı ve ayrıntılı araştırma README’dedir.
- Başlangıçta ayrı iç not/dış yanıt formları ve imzalı önizleme vardı; metnin anlamı değerlendirilmiyordu.

## Acı
- Müşteri destek görevlisi yanlış kutuya ekip içi bilgi yazıp müşteriye gönderebilir. Meghann O., Customer Success Manager, 8 Eylül 2025, “Lots of functionality but difficult to navigate”: iç not yerine müşteriye yanıt göndermenin kolaylığı. [Capterra yorumları](https://www.capterra.com/p/164283/Zendesk/reviews/). Kaynak mevcut ürünün hiç koruması olmadığını ispatlamaz; kullanıcı deneyimindeki hata riskini gösterir.

## Bu haftanın vaadi
“Talep akışını, ayrı iç not formunu ve önizlemeyi çalışır hâle getirdim. Üzerine dış yanıt taslağının anlamını LLM ile kontrol eden bir koruma ekleyeceğim. Riskte gönder düğmesi görünmeyecek, ‘Emin misin?’ uyarısı ve gerekçe çıkacak. Taslak düzeltilebilecek veya iç nota alınabilecek. Kontrol tamamlanamazsa gönderilmeyecek.”

## Yapılanlar ve kanıt
- [Başlangıç vaadi commit'i](https://github.com/umitefe0/pusula-destek/commit/3597836).
- Groq structured JSON sınıflandırması, riskli/belirsiz içerikte gönder düğmesinin kaldırılması, düzeltme ve ekip içi nota kaydetme eklendi.
- Sunucu kontrolü aynı talep/görevli/metin ve 15 dakika koşulunu zorunlu kılıyor. API hatası, kota ve eksik anahtar gönderimi açmıyor.
- 23 Ekim yerel doğrulama: **52 test, 304 assertion, 0 failure/error/skip**. Zeitwerk ve assets derlemesi geçti. Testler gerçek API çağırmaz; sağlayıcı taklidi kullanılır.
- Yerel tarayıcıda eksik anahtar durumunda taslağın korunduğu ve gönder düğmesinin bulunmadığı görüldü.
- Kod: [e602b57 — LLM ve sunucu koruması](https://github.com/umitefe0/pusula-destek/commit/e602b57fac19429a04a2ef3ec9a1906b5513107d), [0b72ce1 — ağ hatası davranışı](https://github.com/umitefe0/pusula-destek/commit/0b72ce18a6e3dfb7c980f2ddc9a33915dbe25ec2).
- [0b72ce1 GitHub Actions](https://github.com/umitefe0/pusula-destek/actions/runs/39942188766) başarılı: migration, autoload, test ve assets adımları yeşil.
- Render 23 Ekim 13:54 Türkiye saatinde 0b72ce1 sürümünü canlıya aldı; PostgreSQL migration başarılı.
- İlk gerçek Groq denemesinde riskli taslak `blocked`, uygun yanıt `safe` döndü. Riskli metin iç nota kaydedildi; uygun yanıt gönderildi ve müşteri görünümünde iç notun bulunmadığı doğrulandı.
- İlk uygun yanıtın gerekçesi İngilizce geldi. Bu gözlem gizlenmedi; [06d3216](https://github.com/umitefe0/pusula-destek/commit/06d3216) ile Türkçe açıklama talimatı güçlendirildi. 24 Ekim canlı kontrolde Türkçe gerekçe geldi; ancak uygun bir ekibe aktarma mesajında yanlış engelleme görüldü. [İlk değerlendirme kaydı](docs/evidence/live-evaluation-before-calibration.json) bu başarısızlığı içerir. Muhatap/amaç ayrımı ve modelin düşünme düzeyi buna göre düzeltildi; son doğrulama aşağıdadır.
- [7a4f7bc](https://github.com/umitefe0/pusula-destek/commit/7a4f7bcba49d0d50a8bbe74bfb5697696326797a): müşteri durum bildirimi ile ekip içi talimat ayrımı; model düşünme düzeyi medium. [GitHub Actions](https://github.com/umitefe0/pusula-destek/actions/runs/40085962679) başarılı.
- 24 Ekim son canlı sürüm **7a4f7bc** Render'da başarıyla yayımlandı. Gerçek Groq çağrısıyla **8 sentetik örneğin 8'i beklenen sınıfta**: 4 uygun, 4 engellenen. Biri prompt talimatını değiştirmeye çalışan sentetik parola metni; biri önceki yanlış engellemeyi tekrar deneyen örnek. [Ham sonuçlar ve model gerekçeleri](docs/evidence/live-evaluation-final.json). Bu küçük, geliştirme sırasında seçilmiş set genel doğruluk oranı veya bağımsız benchmark değildir.
- Riskli taslak düzeltildi, yeni kontrol alındı ve uygun yanıt canlı portalda gönderildi. [Engelleme](docs/evidence/live-blocked-final.png), [onay](docs/evidence/live-safe-final.png), [gönderilmiş yanıt](docs/evidence/live-sent-final.png). Önceki gün tamamlanan iç nota kaydetme/müşteriden gizleme kanıtı: [müşteri ekranı](docs/evidence/live-customer.png).
- `/up` 24 Ekim kontrolünde HTTP 200 döndü. Gerçek sağlayıcıyla denemeler tarayıcı formundan yapıldı; `script/evaluate_content_guard.rb` betiği ayrıca çalıştırılmadı ve çalıştırılmış gibi sunulmuyor.
- Bu haftanın vaat edilen koruma akışı tamamlandı. Otomatik testler sağlayıcı taklidiyle, yukarıdaki canlı denemeler gerçek API ile yapıldı.
- Demo adımları ve kod haritası: [ikinci hafta sunumu](docs/hafta-2-sunum.md).
- Yapılamayanlar: geniş kullanıcı deneyi/doğruluk ölçümü, RAG ve agent-first akış yok. Bunlar bu haftanın vaadi değildi. LLM kontrolü yüzde yüz sızıntı önleme değildir.

## Zaman
- İlk uygulama prompt'u (olduğu gibi): `tamam yapalım ödevi`
- Bundan önce öğretmenin ödev metni paylaşıldı ve kapsam konuşuldu.
- Agent zaman ölçüm kaydı başlangıcı: 23 Ekim 2026 13:38:47 Türkiye saati (10:38:47 UTC). Bu, ilk incelemenin birkaç dakika sonrasındaki ölçümdür; önceki süre ölçülmedi.
- İnsan zamanı: öğrencinin kendi beyanı **yaklaşık 30 dakika** (okuma, hesap/anahtar işlemleri ve deneme); kronometre ölçümü değildir.
- Agent çalışması iki oturumda yapıldı: 23 Ekim 13:38–13:57 kayıtlı bölüm yaklaşık 18 dakika; 24 Ekim devam oturumunun uygulama doğrulama bölümü 13:24–13:30 yaklaşık 6 dakika; belge/CI kapanışı ayrıca birkaç dakika. Toplam kayıtlı çalışma yaklaşık 25–30 dakika. Aradaki bir günlük kesinti çalışma süresine dahil değildir. Bu süreler araç beklemelerini de içeren duvar saati aralıklarıdır; net model hesaplama zamanı değildir.
- ChatGPT Plus öğrenci beyanı: aylık 20 USD. Bu çalışmada ek ücretli abonelik veya hosting satın alınmadı. Groq anahtarı öğrenci tarafından Render’a eklendi; sağlayıcının token/fatura paneli incelenmedi, gerçek tüketim bedeli ölçülmedi. API erişimi Plus’a dahil varsayılmadı.

## Karar
**Devam, daha dar odak:** Genel destek ürünü yerine dış yanıtta ekip içi bilgi sızıntısı riskini azaltmaya odaklanıyoruz. Mevcut talep akışı üzerinde bu kontrolü göstermek yeni bir ürün kurmaktan daha kısa doğrulama yolu. Destek yöneticisinin hatalı gönderim ve müşteri güven kaybını azaltmak için ödeme yapabileceği bir iş hipotezi var; müşteri görüşmesi veya ödeme ile henüz doğrulanmadı. LLM hata yapabilir; tam sızıntı önleme vaadi yoktur.
