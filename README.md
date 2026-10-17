# Pusula Destek

[![Rails tests](https://github.com/umitefe0/pusula-destek/actions/workflows/ci.yml/badge.svg)](https://github.com/umitefe0/pusula-destek/actions/workflows/ci.yml)

Ruby on Rails 8.1 ile müşteri talebi → atama → yanıt → çözüm → yeniden açma. Kendi adımız ve pusula logomuz vardır. İlham kaynağı **Zendesk**; ürünle bağlantılı değiliz.

- **Canlı URL: https://pusula-destek.onrender.com**
- [5 dakikalık sunum provası ve kod haritası](docs/sunum.md)
- Repo: https://github.com/umitefe0/pusula-destek
- Çalışma kuralları: [AGENT.md](AGENT.md); [ilk sürüm](docs/agent-initial.md).

## Aort dilimi ve zaman kuralları

Müşteri talep açar; görevli üstlenir, iç not ekleyebilir, müşteriye yanıtı önizleyip gönderir. Müşteri yanıt verince talep işlemde durumuna döner. Görevli çözer; müşteri süre dolmadan yeniden açar.

| Kural | Sınır |
|---|---|
| İlk görevli yanıtı | 4 takvim saati; eşitlikte gecikmiş |
| Müşteriden yanıt bekleme | 3 gün; eşitlikte takip gerekli |
| Yeniden açma | Çözümden itibaren 7 gün dolmadan; eşitlikte kapalı |

İç not ve müşteri mesajı ilk yanıt saatini durdurmaz. Atanmamış veya henüz yanıtlanmamış talep çözülemez. Durum değişiklikleri aktörüyle kaydedilir. Uyarılar sayfa isteğinde hesaplanır.

Demo girişinde tarayıcı oturumuna özel çalışma alanı oluşturulur. Aynı oturumda müşteri/görevli geçişi sunum içindir, gerçek kimlik doğrulama değildir. Gerçek/hassas veri girmeyin.

## Faz 1 — Fortune 500 genel tablosu

Evren sabit **2025 ABD Fortune 500** listesidir; Global 500 değildir. Gelir, piyasa değeri ve özel şirket değerlemesi farklıdır. Bütün 500 şirketin karşılaştırılabilir değerlemesi mevcut değildir.

| Ölçü | Sonuç | Kaynak/kapsam |
|---|---|---|
| Gözlenebilen piyasa değeri | QVC Group: 139,8 milyon dolar; Apple: 3.336.853,1 milyon dolar | [Fortune 2025](https://www.fortune.com/ranking/fortune500/2025/); 472 dolu, 28 eksik kayıt; güncel fiyat değildir. |
| Çalışan aralığı | Gold.com: 486; Walmart: 2.100.000 | [Fortune 2025](https://www.fortune.com/ranking/fortune500/2025/); 500 kayıt, sayfadaki mevcut şirket adları. |
| Yaklaşık SaaS sayısı göstergesi | Şirket başına ortalama 305 | [Zylo 2026](https://zylo.com/blog/saas-statistics); Zylo örneklemi, Fortune 500 sayımı değil. |
| Yıllık SaaS harcaması göstergesi | Örneklem ortalaması 55,7 milyon dolar; 10.000 üzeri çalışanlı işletmelerde 123,5–375,5 milyon dolar | [Zylo 2026](https://zylo.com/blog/saas-statistics); Fortune 500 firmalarının kesin bütçeleri değildir. |

Yöntem: Fortune sayfasındaki kamuya açık tablo verisinde sıra 1–500 şirketleri tekilleştirip çalışan ve dolu piyasa değeri alanlarında minimum/maksimum hesaplandı. Özel şirketlerde eksik piyasa değerleri sıfır sayılmadı. SaaS rakamları ayrı bir araştırma örnekleminden yaklaşık gösterge olarak alındı. Kaynaklar Ekim 2026 çalışma oturumlarında incelendi. [Hesap betiği](docs/fortune_ranges.py) ve [hesap çıktısı](docs/fortune-range-results.json) repodadır; kaynak tablonun tamamı yeniden dağıtılmaz.

## SaaS seçimi ve ödeme kanıtı

Stanley Black & Decker, [13 Şubat 2025 tarihli resmi yazısında](https://www.stanleyblackanddecker.com/news-stories/stories/engineering-careers-at-stanley-black-and-decker) Fortune 500 şirketi olduğunu belirtir; 2025 listesinde 283. sıradadır.

[Resmi Zendesk müşteri hikâyesi](https://www.zendesk.com.mx/customer/stanley-black-decker/) Support, Guide, Chat ve Talk paketinin satın alınmasını ve profesyonel hizmet sözleşmesini anlatır. Bu, tarihsel ücretli kullanım kanıtıdır; 2026 sözleşmesinin sürdüğü ayrıca doğrulanmadı. Ödeme gerekçesi farklı kanallardan gelen müşteri taleplerini tek yerde yönetip hızlı yanıtlamaktır.

## Kullanıcı acısı ve çözüm

[Capterra yorumları](https://www.capterra.com/p/164283/Zendesk/reviews/): **Meghann O.**, Customer Success Manager, **8 Eylül 2025**, “Lots of functionality but difficult to navigate”. Kullanıcı iç not yerine yanlışlıkla müşteriye yanıt göndermenin kolaylığından yakınıyor.

Sunum cümlesi: **Destek görevlisinin iç notu yanlışlıkla müşteriye gönderme acısını, Meghann O.'nun Capterra yorumundan aldım; ayrı iç not alanı ve alıcısı görünen zorunlu yanıt önizlemesiyle çözdüm.**

Ayrı form/uç nokta, 15 dakika geçerli imzalı önizleme ve çift gönderimi önleyen anahtar kullanılır. Müşteri sorguları iç notları dışarıda bırakır. Orijinal üründe iç not olmadığı iddia edilmiyor; çözüm bir kullanılabilirlik tercihidir. Kullanıcı deneyinde ölçülmüş hata azalması yoktur.

## Faz 2 — boyut, süre ve maliyet

Orijinal kod kapalıdır; doğrulanmış satır sayısı yoktur. **Yaklaşık 300.000 satır**, 200–500 bin belirsizlik aralığıyla kendi mühendislik tahminimizdir, satıcı verisi değildir. Varsayımsal dağılım: talep/iş akışı 70 bin, çok kanallı iletişim 60 bin, hesap/yetki 40 bin, otomasyon/SLA 40 bin, arama/raporlama 50 bin, bilgi bankası 40 bin. Yukarıdaki resmi müşteri hikâyesi kurumsal modül kapsamını destekler; sayısal dağılım bizim varsayımımızdır.

Bu repodaki app/config/db/test kaynakları 36 dosyada 1.139 fiziksel satırdır (Ruby, ERB, CSS, SVG, YAML; boş satırlar dahil; bağımlılıklar hariç). Sıkıştırılmış CSS/ERB nedeniyle bu sayı ürün karmaşıklığının ölçüsü değildir.

Bu aort dilimi için başlangıç tahmini **2–4 aktif gün**, 2–6 milyon giriş ve 0,4–1 milyon çıkış tokenı. [GPT-5.4 resmi fiyatı](https://developers.openai.com/api/docs/models/gpt-5.4) karşılaştırma ölçütüyle (milyon giriş 2,50 dolar, çıkış 15 dolar) **11–30 dolar**, iki kat deneme payıyla **22–60 dolar**. Uzun bağlam ek ücretleri uygulanmayan istekler varsayılmıştır. Bu hesap kullanılan Codex oturumunun faturası değildir.

300 bin satırlık daha geniş çekirdek için ayrı kaba senaryo: satır başına 10 çıkış tokenı ve 2–3 üretim/onarım turu = 6–9 milyon çıkış; 20–40 milyon girişle **140–235 dolar ham model bedeli**. Entegrasyon ve insan doğrulaması dahil **20–60 aktif gün** öngörüsü deneyle doğrulanmadı. Bu hesap kurumsal ürün eşdeğerliğini veya operasyon maliyetlerini kapsamaz.

**Gerçekleşen:** Çalışma 12 Ekim'de başladı, 17 Ekim'de devam etti; kesinti nedeniyle beş takvim günü beş aktif gün değildir. Aktif süre ve token sayısı ölçülmedi. Ek ücretli API/hosting satın alınmadı. Kullanıcının bildirdiği mevcut plan **ChatGPT Plus, aylık 20 ABD dolarıdır**. Plus bir abonelik planıdır; model adı değildir. Bu çalışma mevcut abonelik kapsamında yapıldı; ödeve özel ek API/hosting harcaması **0 dolar** oldu. Aylık 20 doların yalnızca bu ödeve düşen payı ve token bazlı karşılığı ölçülmedi; bu nedenle 20 doların tamamını ödeve özel tüketim olarak göstermiyoruz. Tahmin gerçekleşmiş harcama olarak sunulmuyor.

## Kurulum ve doğrulama

Ruby 3.4.11, Rails 8.1; geliştirme/test SQLite, üretim PostgreSQL.

```sh
bundle config set --local without production
bundle install
bundle exec rails db:prepare
bundle exec rails server
bundle exec rails test
bundle exec rails zeitwerk:check
bundle exec rails assets:precompile
```

Windows önizlemesi: `ruby bin/local-server`. Yerel derleyici ASCII dışı yolda sorun çıkarırsa ASCII sürücü takma adı kullanılabilir. Yerel ortam ve sırlar repoya eklenmez.

17 Ekim 2026 yerel sonuç: **36 test, 179 assertion, 0 failure, 0 error, 0 skip**. Tam zaman sınırları `travel_to(..., with_usec: true)` ile korunur. Linux GitHub Actions doğrulaması da [başarıyla tamamlandı](https://github.com/umitefe0/pusula-destek/actions/runs/38976881107) (e8b4acb). CI rozeti en güncel çalıştırmayı gösterir.

## Deploy

Render ilk kez kullanılan platformdur. `render.yaml` ücretsiz web servisi ve PostgreSQL tanımlar. Build `bash bin/render-build.sh`; start `bundle exec puma -C config/puma.rb`; sağlık `/up`. SECRET_KEY_BASE Render'da üretilir; DATABASE_URL veritabanından alınır. Herkese açık Git URL'siyle kurulduğu için otomatik deploy bağlantısı yoktur; kod değişince Render panelinde Manual Deploy → Deploy latest commit kullanılır.

[Ücretsiz plan](https://render.com/docs/free): web servisi 15 dakika hareketsizlikte uyuyabilir; ücretsiz PostgreSQL 30 gün sonra sona erer. Sunum öncesi uygulamayı açıp uyandırın ve panelde veritabanı süresini kontrol edin. Oluşturulan ücretsiz veritabanının panelde görünen bitiş tarihi **16 Kasım 2026**. [Rails 8 deploy belgesi](https://render.com/docs/deploy-rails-8). Veriler geçici uygulama diskinde değil PostgreSQL'de tutulur.

## Sunum ve kod haritası

- 30 sn: ürün, kaynaklı kurumsal ödeme gerekçesi.
- 2 dk: müşteri talep aç → görevli üstlen → iç not → önizle ve yanıtla → müşteri yanıtla → görevli çöz → müşteri yeniden aç.
- 1 dk: `app/models/ticket.rb` süre sabitleri ve TRANSITIONS; `app/services/ticket_workflow.rb` geçiş metotları; `test/models/ticket_test.rb` sınır testleri.
- 1 dk: yorumdaki acı ve ayrı iç not/önizleme çözümü; eksikler.
- 30 sn: “SLA hafta sonunu saymasın” için model süre kuralı ve `app/controllers/tickets_controller.rb` son tarih hesabı. Yalnızca 4.hours değiştirilmez: ortak iş takvimi hesabı ve cuma/hafta sonu testleri gerekir; `app/services/demo_workspace.rb` de aynı hesabı kullanmalıdır.

## Yapamadıklarım

- Gerçek hesap/parola/SSO yok; demo rolleri değiştirilebilir.
- Gerçek e-posta/SMS, dosya eki ve dış kanal entegrasyonu yok; yanıt portalda görünür.
- Çalışma saatleri, resmi tatil, hafta sonu istisnası yok.
- Arka plan bildirimi yok; uyarı sayfa yenilendiğinde hesaplanır.
- Kurumsal ölçek/yük testi, bağımsız güvenlik denetimi ve erişilebilirlik sertifikası yok.
- Tam ürün klonu, doğrulanmış orijinal satır sayısı, gerçek token/fatura ölçümü yok.
- Kullanıcı deneyinde ölçülmüş hata azalması yok.
- G1–G5 tanımları sağlanmadı; kendi belgelerimiz resmi G1–G5 diye adlandırılmadı.

17 Ekim 2026 canlı tarayıcı kontrolü tamamlandı: talep oluşturma → üstlenme → iç not → alıcı önizlemesi → müşteriye yanıt → müşteri yanıtı → çözme → müşteri olarak yeniden açma. Müşteri görünümünde iç notun bulunmadığı ayrıca kontrol edildi. /up sağlık kontrolü HTTP 200 döndü. Sunumda yalnızca gerçekten çalışan özellikler gösterilir.
