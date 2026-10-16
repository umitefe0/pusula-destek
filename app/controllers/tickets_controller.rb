class TicketsController < ApplicationController
  before_action :require_agent, only: [:assign, :resolve, :preview_reply, :reply, :internal_note]
  before_action :set_ticket, except: [:index, :new, :create]
  rescue_from Ticket::InvalidTransition, ActiveRecord::RecordInvalid, with: :workflow_error

  def index
    base = accessible_tickets
    @counts = { active: base.active.count, overdue: base.overdue.count, follow_up: base.needs_follow_up.count, solved: base.solved.count }
    @filter = params[:filter].presence || "all"
    @tickets = case @filter
    when "overdue" then base.overdue
    when "follow_up" then base.needs_follow_up
    when "unassigned" then base.new_ticket
    when "solved" then base.solved
    else base.active
    end
    if params[:q].present?
      @tickets = @tickets.where("subject LIKE ?", "%#{Ticket.sanitize_sql_like(params[:q].to_s.first(160))}%")
    end
    @tickets = @tickets.includes(:customer, :assignee).order(first_response_due_at: :asc, id: :asc).limit(100)
  end

  def new
    raise TicketWorkflow::NotAuthorized unless current_user.customer?
    @ticket = Ticket.new(priority: :normal)
  end

  def create
    raise TicketWorkflow::NotAuthorized unless current_user.customer?
    @ticket = current_workspace.tickets.build(params.require(:ticket).permit(:subject, :description, :priority))
    @ticket.customer = current_user
    @ticket.first_response_due_at = Time.current + Ticket::FIRST_RESPONSE_WINDOW
    Ticket.transaction do
      @ticket.save!
      @ticket.ticket_events.create!(actor: current_user, action: "created", to_status: @ticket.status)
    end
    redirect_to @ticket, notice: "Talebiniz alındı. İlk yanıt hedefimiz 4 saat."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def show
    @messages = @ticket.messages.includes(:author).order(:created_at, :id)
    @messages = @messages.where(visibility: :public_reply) if current_user.customer?
    @events = @ticket.ticket_events.includes(:actor).order(:created_at, :id)
  end

  def assign
    workflow.assign!
    redirect_to @ticket, notice: "Talebi üstlendiniz."
  end

  def resolve
    workflow.resolve!
    redirect_to @ticket, notice: "Talep çözüldü. Müşteri 7 gün içinde yeniden açabilir."
  end

  def reopen
    workflow.reopen!
    redirect_to @ticket, notice: "Talep yeniden açıldı."
  end

  def preview_reply
    raise Ticket::InvalidTransition, "Önce talebi üstlenin." unless @ticket.open? || @ticket.pending?
    @draft = @ticket.messages.build(author: current_user, body: params[:body].to_s.strip, visibility: :public_reply)
    if @draft.valid?
      @preview_token = verifier.generate({ ticket_id: @ticket.id, author_id: current_user.id, body: @draft.body, key: SecureRandom.uuid }, expires_in: 15.minutes, purpose: :public_reply)
    else
      raise ActiveRecord::RecordInvalid, @draft
    end
  end

  def reply
    draft = verifier.verified(params[:preview_token], purpose: :public_reply)&.with_indifferent_access
    unless draft && draft[:ticket_id] == @ticket.id && draft[:author_id] == current_user.id
      raise Ticket::InvalidTransition, "Önizleme geçersiz veya 15 dakikalık süresi doldu. Yanıtı yeniden önizleyin."
    end
    workflow.public_reply!(body: draft[:body], submission_key: draft[:key])
    redirect_to @ticket, notice: "Yanıt müşteriye gönderildi."
  end

  def internal_note
    workflow.internal_note!(body: params[:body].to_s.strip)
    redirect_to @ticket, notice: "İç not yalnızca ekibe kaydedildi. Müşteriye gönderilmedi."
  end

  def customer_reply
    workflow.customer_reply!(body: params[:body].to_s.strip)
    redirect_to @ticket, notice: "Mesajınız destek ekibine iletildi."
  end

  private

  def accessible_tickets
    current_user.agent? ? current_workspace.tickets : current_workspace.tickets.where(customer: current_user)
  end

  def set_ticket = @ticket = accessible_tickets.find(params[:id])
  def workflow = TicketWorkflow.new(@ticket, current_user)
  def verifier = Rails.application.message_verifier(:reply_preview)

  def workflow_error(error)
    redirect_to ticket_path(@ticket), alert: error.message
  end
end
