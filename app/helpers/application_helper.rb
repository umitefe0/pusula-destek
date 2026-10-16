module ApplicationHelper
  def status_label(ticket)
    { "new_ticket" => "Yeni", "open" => "İşlemde", "pending" => "Müşteri bekleniyor", "solved" => "Çözüldü" }.fetch(ticket.status)
  end

  def priority_label(ticket)
    { "low" => "Düşük", "normal" => "Normal", "high" => "Yüksek" }.fetch(ticket.priority)
  end

  def event_label(event)
    { "created" => "Talep oluşturuldu", "assigned" => "Talep üstlenildi", "replied" => "Müşteriye yanıt gönderildi", "customer_replied" => "Müşteri yanıtladı", "resolved" => "Talep çözüldü", "reopened" => "Talep yeniden açıldı" }.fetch(event.action, event.action)
  end

  def clock_label(time)
    time&.in_time_zone&.strftime("%d.%m.%Y · %H:%M") || "—"
  end

  def duration_label(seconds)
    minutes = (seconds.abs / 60).ceil
    minutes < 60 ? "#{minutes} dk" : "#{minutes / 60} sa #{minutes % 60} dk"
  end

  def sla_label(ticket)
    if ticket.first_response_at
      ticket.first_response_at <= ticket.first_response_due_at ? "Zamanında yanıtlandı" : "Gecikmeli yanıtlandı"
    elsif ticket.overdue?
      "#{duration_label(Time.current - ticket.first_response_due_at)} gecikti"
    else
      "#{duration_label(ticket.first_response_due_at - Time.current)} kaldı"
    end
  end
end
