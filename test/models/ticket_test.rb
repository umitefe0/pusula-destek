require "test_helper"

class TicketTest < ActiveSupport::TestCase
  setup { make_workspace }

  test "first response is not overdue one second before boundary" do
    travel_to @ticket.first_response_due_at - 1.second do
      assert_not @ticket.overdue?
      assert_not Ticket.overdue.exists?(@ticket.id)
    end
  end

  test "first response becomes overdue exactly at deadline" do
    travel_to @ticket.first_response_due_at, with_usec: true do
      assert @ticket.overdue?
      assert Ticket.overdue.exists?(@ticket.id)
    end
  end

  test "first response stays overdue after deadline" do
    travel_to @ticket.first_response_due_at + 1.second do
      assert @ticket.overdue?
    end
  end

  test "internal note does not stop first response clock" do
    TicketWorkflow.new(@ticket, @agent).internal_note!(body: "Özel ekip notu")
    travel_to @ticket.first_response_due_at + 1.minute do
      assert @ticket.reload.overdue?
      assert_nil @ticket.first_response_at
    end
  end

  test "customer followup does not stop first response clock" do
    TicketWorkflow.new(@ticket, @customer).customer_reply!(body: "Bir gelişme var mı?")
    assert_nil @ticket.reload.first_response_at
  end

  test "public reply stops clock and first response time is immutable through later replies" do
    public_answer
    first = @ticket.reload.first_response_at
    travel_to @ticket.first_response_due_at + 2.hours do
      TicketWorkflow.new(@ticket, @agent).public_reply!(body: "Yeni gelişme", submission_key: SecureRandom.uuid)
      assert_equal first, @ticket.reload.first_response_at
      assert_not @ticket.overdue?
    end
  end

  test "followup is not due one second before three days" do
    public_answer
    travel_to @ticket.waiting_since + 3.days - 1.second do
      assert_not @ticket.follow_up_due?
    end
  end

  test "followup is due exactly at three days and included in queue" do
    public_answer
    travel_to @ticket.waiting_since + 3.days, with_usec: true do
      assert @ticket.follow_up_due?
      assert Ticket.needs_follow_up.exists?(@ticket.id)
    end
  end

  test "followup remains due after three days" do
    public_answer
    travel_to @ticket.waiting_since + 3.days + 1.second do
      assert @ticket.follow_up_due?
    end
  end

  test "customer reply clears pending clock and returns to open" do
    public_answer
    TicketWorkflow.new(@ticket, @customer).customer_reply!(body: "İstenen bilgiyi paylaşıyorum")
    assert @ticket.reload.open?
    assert_nil @ticket.waiting_since
    travel_to 5.days.from_now do
      assert_not @ticket.follow_up_due?
    end
  end

  test "reopen permitted until one second before seven days" do
    public_answer
    TicketWorkflow.new(@ticket, @agent).resolve!
    travel_to @ticket.solved_at + 7.days - 1.second do
      assert @ticket.reopenable?
      TicketWorkflow.new(@ticket, @customer).reopen!
      assert @ticket.reload.open?
      assert_nil @ticket.solved_at
    end
  end

  test "reopen prohibited exactly at seven days" do
    public_answer
    TicketWorkflow.new(@ticket, @agent).resolve!
    travel_to @ticket.solved_at + 7.days, with_usec: true do
      assert_not @ticket.reopenable?
      assert_raises(Ticket::InvalidTransition) { TicketWorkflow.new(@ticket, @customer).reopen! }
      assert @ticket.reload.solved?
    end
  end

  test "reopen prohibited after seven days even through direct update" do
    public_answer
    TicketWorkflow.new(@ticket, @agent).resolve!
    travel_to @ticket.solved_at + 7.days + 1.second do
      assert_not @ticket.update(status: :open, solved_at: nil)
      assert @ticket.reload.solved?
    end
  end

  test "new ticket cannot be resolved or directly moved to solved" do
    assert_raises(Ticket::InvalidTransition) { TicketWorkflow.new(@ticket, @agent).resolve! }
    assert_not @ticket.update(status: :solved, solved_at: Time.current)
    assert @ticket.reload.new_ticket?
  end

  test "assignment alone is not enough to resolve a ticket" do
    TicketWorkflow.new(@ticket, @agent).assign!
    assert_raises(Ticket::InvalidTransition) { TicketWorkflow.new(@ticket, @agent).resolve! }
    assert @ticket.reload.open?
  end

  test "public reply before assignment is rejected without message or event" do
    assert_no_difference ["Message.count", "TicketEvent.count"] do
      assert_raises(Ticket::InvalidTransition) { TicketWorkflow.new(@ticket, @agent).public_reply!(body: "Yanıt", submission_key: "unassigned") }
    end
  end

  test "all core transitions are logged with actor" do
    flow = TicketWorkflow.new(@ticket, @agent)
    flow.assign!
    flow.public_reply!(body: "Çözdük", submission_key: SecureRandom.uuid)
    flow.resolve!
    assert @ticket.solved?
    assert_equal %w[assigned replied resolved], @ticket.ticket_events.order(:id).pluck(:action)
    assert_equal [@agent.id], @ticket.ticket_events.pluck(:actor_id).uniq
  end

  test "blank reply rolls back all changes" do
    TicketWorkflow.new(@ticket, @agent).assign!
    assert_no_difference ["Message.count", "TicketEvent.count"] do
      assert_raises(ActiveRecord::RecordInvalid) { TicketWorkflow.new(@ticket, @agent).public_reply!(body: "", submission_key: "invalid") }
    end
    assert @ticket.reload.open?
    assert_nil @ticket.first_response_at
  end

  test "repeat submission is idempotent" do
    flow = TicketWorkflow.new(@ticket, @agent)
    flow.assign!
    flow.public_reply!(body: "Tek yanıt", submission_key: "same-key")
    assert_no_difference ["Message.count", "TicketEvent.count"] do
      flow.public_reply!(body: "Tek yanıt", submission_key: "same-key")
    end
  end

  test "customer cannot assign resolve or create internal notes" do
    flow = TicketWorkflow.new(@ticket, @customer)
    assert_raises(TicketWorkflow::NotAuthorized) { flow.assign! }
    assert_raises(TicketWorkflow::NotAuthorized) { flow.resolve! }
    assert_raises(TicketWorkflow::NotAuthorized) { flow.internal_note!(body: "Deneme") }
  end

  test "another workspace cannot participate" do
    other = Workspace.create!(name: "Other")
    outsider = other.users.create!(name: "Other agent", email: "other@example.test", role: :agent)
    assert_raises(TicketWorkflow::NotAuthorized) { TicketWorkflow.new(@ticket, outsider) }
    assert_not @ticket.update(assignee: outsider)
  end

  test "message validation blocks cross-customer and internal injection" do
    stranger = @workspace.users.create!(name: "Other customer", email: "another@example.test", role: :customer)
    assert_not @ticket.messages.build(author: stranger, body: "No", visibility: :public_reply).valid?
    assert_not @ticket.messages.build(author: @customer, body: "No", visibility: :internal).valid?
  end

  test "solved ticket cannot receive public replies without reopening" do
    public_answer
    TicketWorkflow.new(@ticket, @agent).resolve!
    assert_raises(Ticket::InvalidTransition) { TicketWorkflow.new(@ticket, @customer).customer_reply!(body: "Mesaj") }
    assert_raises(Ticket::InvalidTransition) { TicketWorkflow.new(@ticket, @agent).public_reply!(body: "Mesaj", submission_key: "closed") }
  end
end
