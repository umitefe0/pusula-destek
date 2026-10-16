class Ticket < ApplicationRecord
  FIRST_RESPONSE_WINDOW = 4.hours
  FOLLOW_UP_WINDOW = 3.days
  REOPEN_WINDOW = 7.days
  TRANSITIONS = {
    "new_ticket" => %w[open], "open" => %w[pending solved],
    "pending" => %w[open solved], "solved" => %w[open]
  }.freeze
  class InvalidTransition < StandardError; end

  belongs_to :workspace
  belongs_to :customer, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :messages, dependent: :destroy
  has_many :ticket_events, dependent: :destroy
  enum :status, { new_ticket: 0, open: 1, pending: 2, solved: 3 }, validate: true
  enum :priority, { low: 0, normal: 1, high: 2 }, prefix: true, validate: true

  validates :subject, :description, :first_response_due_at, presence: true
  validates :subject, length: { maximum: 160 }
  validates :description, length: { maximum: 10_000 }
  validate :participants_belong_to_workspace
  validate :status_transition_is_allowed, on: :update
  validate :state_is_consistent

  scope :unanswered, -> { where(first_response_at: nil) }
  scope :overdue, -> { unanswered.where(first_response_due_at: ..Time.current) }
  scope :needs_follow_up, -> { where(status: :pending).where(waiting_since: ..(Time.current - FOLLOW_UP_WINDOW)) }
  scope :active, -> { where.not(status: :solved) }

  def overdue?(at: Time.current)
    first_response_at.nil? && at >= first_response_due_at
  end

  def follow_up_due?(at: Time.current)
    pending? && waiting_since.present? && at >= waiting_since + FOLLOW_UP_WINDOW
  end

  def reopenable?(at: Time.current)
    solved? && solved_at.present? && at < solved_at + REOPEN_WINDOW
  end

  def reopen_deadline = solved_at && solved_at + REOPEN_WINDOW
  def follow_up_deadline = waiting_since && waiting_since + FOLLOW_UP_WINDOW

  private

  def participants_belong_to_workspace
    errors.add(:customer, "bu çalışma alanında müşteri olmalı") unless customer&.customer? && customer.workspace_id == workspace_id
    if assignee && (!assignee.agent? || assignee.workspace_id != workspace_id)
      errors.add(:assignee, "bu çalışma alanında görevli olmalı")
    end
  end

  def status_transition_is_allowed
    return unless will_save_change_to_status?
    previous = status_in_database
    errors.add(:status, "geçişine izin verilmiyor") unless TRANSITIONS.fetch(previous, []).include?(status)
    if previous == "solved" && !(solved_at_in_database && Time.current < solved_at_in_database + REOPEN_WINDOW)
      errors.add(:status, "yeniden açma süresi doldu")
    end
  end

  def state_is_consistent
    errors.add(:assignee, "önce atanmalı") unless new_ticket? || assignee.present?
    errors.add(:first_response_at, "çözümden önce yanıt gerekli") if solved? && first_response_at.nil?
    errors.add(:solved_at, "çözüm zamanı gerekli") if solved? && solved_at.nil?
    errors.add(:waiting_since, "bekleme zamanı gerekli") if pending? && waiting_since.nil?
  end
end
