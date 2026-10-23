require "test_helper"

class ReplyGuardTest < ActiveSupport::TestCase
  setup do
    make_workspace
    @flow = TicketWorkflow.new(@ticket, @agent)
    @flow.assign!
    @body = "Fatura bağlantınızı düzelttik."
    @review = approved_review(@body)
  end

  def reject_reply(review: @review, body: @body)
    assert_no_difference ["Message.count", "TicketEvent.count"] do
      assert_raises(Ticket::InvalidTransition) do
        @flow.public_reply!(body:, review:, submission_key: SecureRandom.uuid)
      end
    end
    assert_nil @ticket.reload.first_response_at
  end

  test "missing review and changed draft cannot bypass server guard" do
    reject_reply(review: nil)
    reject_reply(body: "Ekip: bu bilgiyi müşteriden saklayın.")
  end

  test "blocked uncertain checking unavailable reviews cannot authorize a reply" do
    %w[blocked uncertain checking unavailable].each do |state|
      @review.update!(status: state)
      reject_reply
    end
  end

  test "review is bound to both ticket and agent" do
    other_agent = @workspace.users.create!(name: "İkinci", email: "second@example.test", role: :agent)
    @review.update!(author: other_agent)
    reject_reply
    other_ticket = @workspace.tickets.create!(customer: @customer, subject: "Başka", description: "Başka", first_response_due_at: 4.hours.from_now)
    @review.update!(author: @agent, ticket: other_ticket)
    reject_reply
  end

  test "review expires exactly at fifteen minute boundary" do
    deadline = @review.expires_at
    travel_to deadline - 1.second, with_usec: true do
      assert @review.permits?(ticket: @ticket, author: @agent, body: @body)
    end
    travel_to deadline, with_usec: true do
      reject_reply
    end
    travel_to deadline + 1.second, with_usec: true do
      reject_reply
    end
  end

  test "workspace quota prevents more provider calls" do
    30.times { approved_review("örnek") }
    guard = Object.new
    guard.define_singleton_method(:call) { |_| raise "Quota must stop HTTP" }
    review = ReviewOutgoingReply.call(ticket: @ticket, author: @agent, body: @body, guard:)
    assert review.status_unavailable?
    assert_match "limiti", review.reason
  end

  test "review service persists the provider decision without storing the draft" do
    fake = Object.new
    fake.define_singleton_method(:call) do |_|
      ContentGuard::Result.new(status: "blocked", category: "internal_information", reason: "Ekip içi bilgi.", model: "test-double")
    end
    review = ReviewOutgoingReply.call(ticket: @ticket, author: @agent, body: @body, guard: fake)
    assert review.status_blocked?
    assert_equal Digest::SHA256.hexdigest(@body), review.body_digest
    assert_not review.attributes.values.include?(@body)
  end
end
