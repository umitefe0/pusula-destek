require "digest"

class ReplyReview < ApplicationRecord
  belongs_to :ticket
  belongs_to :author, class_name: "User"
  enum :status, { checking: "checking", safe: "safe", blocked: "blocked", uncertain: "uncertain", unavailable: "unavailable" }, prefix: true, validate: true
  validates :body_digest, :category, :reason, :model, :expires_at, presence: true

  def permits?(ticket:, author:, body:)
    persisted? && status_safe? && ticket_id == ticket.id && author_id == author.id &&
      expires_at > Time.current && body_digest == Digest::SHA256.hexdigest(body)
  end
end
