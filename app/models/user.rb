class User < ApplicationRecord
  belongs_to :workspace
  enum :role, { customer: 0, agent: 1 }, validate: true
  validates :name, :email, presence: true
  validates :email, uniqueness: { scope: :workspace_id }
end
