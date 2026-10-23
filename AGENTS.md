# Pusula çalışma talimatları

Önce AGENT.md ve CHALLENGE_LOG.md dosyalarını oku. Öğrenci kapsamı: ekip içi metnin müşteriye yanlışlıkla gönderilmesine karşı LLM destekli kontrol.

- Müşteriye giden görevli yanıtı sunucuda onaylanmış, aynı metne/görevliye/talebe bağlı, süresi dolmamış kontrolden geçmeli. Arayüzde düğme gizlemek tek başına yeterli değildir.
- Groq erişilemezse veya sonuç belirsizse gönderim kapalı kalır. Anahtar kelime filtresini LLM gibi sunma. Test doubles yalnız testlerde bulunur.
- Gizli anahtarlar sadece ortam değişkenlerinde tutulur; commit, log ve ekrana yazılmaz. Gerçek kişisel veriyle demo yapılmaz.
- Testleri gerçekten çalıştır; yerel test, GitHub Actions ve gerçek sağlayıcıyla canlı demo kanıtını ayrı kaydet.
- Render Ruby servisi: `bash bin/render-build.sh`; başlangıç: `bundle exec puma -C config/puma.rb`. Build, migration ve assets precompile yapar. `render.yaml` kaynak yapılandırmadır.
- Bu projenin Render servisi public repo üzerinden bağlandığından push otomatik deploy garantisi değildir. CI yeşil olduktan sonra dashboard → Manual Deploy → Deploy latest commit; başarılı commit ve `/up` kontrol edilir.
- Groq değişkenleri: `GROQ_API_KEY` gizli, `GROQ_MODEL=openai/gpt-oss-20b`. Anahtar olmaması uygulamayı çökertmez fakat dış yanıt gönderimini durdurur.
- CHALLENGE_LOG.md vaat, gerçek sonuç, kaynak, commit ve süre ayrımını korur. Ölçülmeyen süre/token maliyeti uydurulmaz.
