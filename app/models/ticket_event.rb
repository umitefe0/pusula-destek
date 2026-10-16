class TicketEvent < ApplicationRecord
  belongs_to :ticket
  belongs_to :actor, class_name: "User"
  validates :action, presence: true
end
