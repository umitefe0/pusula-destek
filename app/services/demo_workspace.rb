class DemoWorkspace
  def self.create!
    Workspace.transaction do
      workspace = Workspace.create!(name: "Demo çalışma alanı")
      customer = workspace.users.create!(name: "Deniz Yılmaz", email: "deniz@example.test", role: :customer)
      agent = workspace.users.create!(name: "Ece Kaya", email: "ece@example.test", role: :agent)
      now = Time.current
      samples = [
        ["Faturamı indiremediğim için ödeme sürecim bekliyor", "Faturayı indir düğmesine bastığımda boş sayfa açılıyor. Yardımcı olabilir misiniz?", :high, 5.hours.ago],
        ["Ekip arkadaşımı çalışma alanına ekleyemiyorum", "Davet bağlantısını açtığımda bağlantı geçersiz uyarısı alıyorum.", :normal, 2.hours.ago],
        ["Bildirim tercihlerimi nasıl değiştirebilirim?", "Günlük özet bildirimlerini açmak istiyorum.", :low, 30.minutes.ago]
      ]
      samples.each do |subject, description, priority, created|
        ticket = workspace.tickets.create!(customer: customer, subject: subject, description: description,
          priority: priority, created_at: created, first_response_due_at: created + Ticket::FIRST_RESPONSE_WINDOW)
        ticket.ticket_events.create!(actor: customer, action: "created", to_status: "new_ticket", created_at: created)
      end
      waiting = workspace.tickets.create!(customer: customer, assignee: agent, subject: "Dışa aktarılan dosyanın tarih biçimi",
        description: "Rapor tarihleri beklediğim biçimde görünmüyor.", status: :pending, priority: :normal,
        created_at: now - 4.days, first_response_due_at: now - 4.days + 4.hours,
        first_response_at: now - 4.days + 1.hour, waiting_since: now - 3.days - 1.hour)
      waiting.messages.create!(author: agent, visibility: :public_reply, body: "Örnek bir tarih biçimi paylaşabilir misiniz?", created_at: waiting.first_response_at)
      waiting.messages.create!(author: agent, visibility: :internal, body: "Ekip notu: tarih biçimi ayarını kontrol edeceğiz. Bu not müşteriye görünmez.")
      workspace
    end
  end
end
