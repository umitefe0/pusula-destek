class Message < ApplicationRecord
  belongs_to :ticket
  belongs_to :author, class_name: "User"
  enum :visibility, { public_reply: 0, internal: 1 }, prefix: true, validate: true
  validates :body, presence: true, length: { maximum: 10_000 }
  validate :author_is_allowed

  private

  def author_is_allowed
    return unless author && ticket
    errors.add(:author, "erişim izni yok") unless author.workspace_id == ticket.workspace_id
    errors.add(:author, "yalnızca kendi talebine yazabilir") if author.customer? && author.id != ticket.customer_id
    errors.add(:visibility, "müşteri iç not yazamaz") if visibility_internal? && !author.agent?
  end
end
