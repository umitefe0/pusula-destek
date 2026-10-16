# All domain writes are explicit, transactional, and locked per ticket.
class TicketWorkflow
  class NotAuthorized < StandardError; end

  def initialize(ticket, actor)
    @ticket, @actor = ticket, actor
    raise NotAuthorized unless actor.workspace_id == ticket.workspace_id
    raise NotAuthorized if actor.customer? && ticket.customer_id != actor.id
  end

  def assign!
    require_agent!
    mutate("assigned") do
      raise Ticket::InvalidTransition, "Bu talep zaten atanmış." unless @ticket.new_ticket?
      @ticket.update!(assignee: @actor, status: :open)
    end
  end

  def public_reply!(body:, submission_key:)
    require_agent!
    mutate("replied") do
      # A signed preview may be submitted twice; do not duplicate the reply/event.
      return @ticket if @ticket.messages.exists?(submission_key: submission_key)
      raise Ticket::InvalidTransition, "Önce talebi üstlenin; çözülmüş talebe yanıt verilemez." unless @ticket.open? || @ticket.pending?
      @ticket.messages.create!(author: @actor, body: body, visibility: :public_reply, submission_key: submission_key)
      @ticket.update!(status: :pending, first_response_at: @ticket.first_response_at || Time.current, waiting_since: Time.current)
    end
  end

  def internal_note!(body:)
    require_agent!
    mutate("noted", log_event: false) do
      @ticket.messages.create!(author: @actor, body: body, visibility: :internal)
    end
  end

  def customer_reply!(body:)
    raise NotAuthorized unless @actor.customer?
    mutate("customer_replied") do
      raise Ticket::InvalidTransition, "Yanıtlamak için talebi yeniden açın." if @ticket.solved?
      @ticket.messages.create!(author: @actor, body: body, visibility: :public_reply)
      @ticket.update!(status: :open, waiting_since: nil) if @ticket.pending?
    end
  end

  def resolve!
    require_agent!
    mutate("resolved") do
      unless (@ticket.open? || @ticket.pending?) && @ticket.first_response_at.present?
        raise Ticket::InvalidTransition, "Çözmeden önce talebi üstlenip müşteriye yanıt verin."
      end
      @ticket.update!(status: :solved, solved_at: Time.current, waiting_since: nil)
    end
  end

  def reopen!
    mutate("reopened") do
      raise Ticket::InvalidTransition, "Talep yalnızca çözümden sonraki 7 gün içinde yeniden açılabilir." unless @ticket.reopenable?
      @ticket.update!(status: :open, solved_at: nil, waiting_since: nil)
    end
  end

  private

  def require_agent!
    raise NotAuthorized unless @actor.agent?
  end

  def mutate(action, log_event: true)
    @ticket.with_lock do
      previous = @ticket.status
      yield
      @ticket.ticket_events.create!(actor: @actor, action: action, from_status: previous, to_status: @ticket.status) if log_event
    end
    @ticket
  end
end
