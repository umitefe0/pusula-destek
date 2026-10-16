ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  def make_workspace
    @workspace = Workspace.create!(name: "Test alanı")
    @customer = @workspace.users.create!(name: "Müşteri", email: "customer@example.test", role: :customer)
    @agent = @workspace.users.create!(name: "Görevli", email: "agent@example.test", role: :agent)
    @ticket = @workspace.tickets.create!(customer: @customer, subject: "Örnek talep", description: "Yardım gerekiyor", first_response_due_at: Time.current + 4.hours)
  end

  def public_answer(ticket = @ticket)
    flow = TicketWorkflow.new(ticket, @agent)
    flow.assign! if ticket.new_ticket?
    flow.public_reply!(body: "Size yardımcı oluyoruz.", submission_key: SecureRandom.uuid)
  end
end
