require "test_helper"

class CoreFlowTest < ActionDispatch::IntegrationTest
  # These integration tests exercise the application using an explicit provider double.
  # Live semantic accuracy is evaluated separately; no API key is used in CI.
  def before_setup
    super
    @guard_result = ContentGuard::Result.new(status: "safe", category: "customer_ready", reason: "Test double", model: "test-double")
  end

  def run
    fake = Object.new
    read_result = -> { @guard_result }
    fake.define_singleton_method(:call) { |_body| read_result.call }
    ContentGuard.stub(:new, -> { fake }) { super }
  end

  def sign_in(role)
    post demo_session_path(role: role)
    assert_redirected_to tickets_path
  end

  def create_ticket
    sign_in("customer")
    post tickets_path, params: { ticket: { subject: "Sunum talebi", description: "Fatura sayfası açılmıyor", priority: "high" } }
    @ticket = Ticket.order(:id).last
    assert_redirected_to ticket_path(@ticket)
    @ticket
  end

  def preview_token
    response.parsed_body.at_css('input[name="preview_token"]')['value']
  end

  test "risky draft hides send and can become private note" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    @guard_result = ContentGuard::Result.new(status: "blocked", category: "internal_information", reason: "Ekip içi bilgi içeriyor.", model: "test-double")
    body = "ÜMİT-DEMO: Bu müşteriye gerçek maliyeti açıklamayalım."
    assert_no_difference "Message.count" do
      post preview_reply_ticket_path(@ticket), params: { body: }
      assert_response :success
      assert_match "Emin misin?", response.body
      assert_select 'form[action=?]', reply_ticket_path(@ticket), count: 0
      assert_select 'input[name=preview_token]', count: 0
      post reply_ticket_path(@ticket), params: { body:, review_id: ReplyReview.last.id, status: "safe" }
    end
    assert_nil @ticket.reload.first_response_at
    post internal_note_ticket_path(@ticket), params: { body: }
    assert @ticket.messages.last.visibility_internal?
    sign_in("customer")
    get ticket_path(@ticket)
    assert_no_match "ÜMİT-DEMO", response.body
  end

  test "uncertain and unavailable results preserve draft but never show send" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    %w[uncertain unavailable].each do |state|
      @guard_result = ContentGuard::Result.new(status: state, category: "uncertain", reason: "Test sonucu", model: "test-double")
      post preview_reply_ticket_path(@ticket), params: { body: "Kaybolmayan taslak" }
      assert_response :success
      assert_select '#review-body', text: "Kaybolmayan taslak"
      assert_select 'form[action=?]', reply_ticket_path(@ticket), count: 0
    end
  end

  test "editing a rejected draft requires a fresh successful review" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    @guard_result = ContentGuard::Result.new(status: "blocked", category: "disrespect", reason: "Uygun değil", model: "test-double")
    post preview_reply_ticket_path(@ticket), params: { body: "İlk taslak" }
    assert_select 'input[name=preview_token]', count: 0
    @guard_result = ContentGuard::Result.new(status: "safe", category: "customer_ready", reason: "Uygun", model: "test-double")
    post preview_reply_ticket_path(@ticket), params: { body: "Düzeltilmiş yanıt" }
    token = preview_token
    post reply_ticket_path(@ticket), params: { preview_token: token }
    assert_equal "Düzeltilmiş yanıt", @ticket.messages.last.body
    assert_equal %w[blocked safe], @ticket.reply_reviews.order(:id).pluck(:status)
  end

  test "end to end customer creates agent assigns notes replies resolves customer reopens" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    assert @ticket.reload.open?
    post internal_note_ticket_path(@ticket), params: { body: "GİZLİ-EKİP-123" }
    post preview_reply_ticket_path(@ticket), params: { body: "Fatura bağlantınızı düzelttik." }
    assert_response :success
    assert_select ".recipient strong", "Deniz Yılmaz"
    assert_no_match "GİZLİ-EKİP-123", response.body
    token = preview_token
    assert_no_difference "Message.count" do
      get ticket_path(@ticket)
    end
    post reply_ticket_path(@ticket), params: { preview_token: token, body: "İstemci manipülasyonu" }
    assert_redirected_to ticket_path(@ticket)
    assert_equal "Fatura bağlantınızı düzelttik.", @ticket.messages.order(:id).last.body
    assert @ticket.reload.pending?
    post resolve_ticket_path(@ticket)
    assert @ticket.reload.solved?
    sign_in("customer")
    get ticket_path(@ticket)
    assert_response :success
    assert_match "Fatura bağlantınızı düzelttik.", response.body
    assert_no_match "GİZLİ-EKİP-123", response.body
    assert_select 'form[action=?]', internal_note_ticket_path(@ticket), count: 0
    post reopen_ticket_path(@ticket)
    assert @ticket.reload.open?
    post customer_reply_ticket_path(@ticket), params: { body: "Şimdi farklı bir hata var" }
    assert_equal "Şimdi farklı bir hata var", @ticket.messages.order(:id).last.body
  end

  test "preview alone does not publish or stop SLA" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    assert_no_difference "Message.count" do
      post preview_reply_ticket_path(@ticket), params: { body: "Henüz gönderilmedi" }
      assert_response :success
    end
    assert_nil @ticket.reload.first_response_at
  end

  test "signed preview expires exactly after fifteen minutes" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    token = nil
    now = Time.current.change(usec: 0)
    travel_to now do
      post preview_reply_ticket_path(@ticket), params: { body: "Eski taslak" }
      token = preview_token
    end
    travel_to now + 15.minutes do
      assert_no_difference "Message.count" do
        post reply_ticket_path(@ticket), params: { preview_token: token }
      end
      assert_redirected_to ticket_path(@ticket)
      assert_match "geçersiz", flash[:alert]
    end
  end

  test "tampered preview cannot be sent" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    assert_no_difference "Message.count" do
      post reply_ticket_path(@ticket), params: { preview_token: "forged", body: "raw body" }
    end
    assert_nil @ticket.reload.first_response_at
  end

  test "customer cannot call agent endpoints" do
    create_ticket
    [assign_ticket_path(@ticket), resolve_ticket_path(@ticket), internal_note_ticket_path(@ticket), preview_reply_ticket_path(@ticket), reply_ticket_path(@ticket)].each do |path|
      post path, params: { body: "deneme" }
      assert_response :forbidden
    end
  end

  test "workspace isolation prevents detail access and mutations from another browser" do
    create_ticket
    foreign_ticket = @ticket
    other = open_session
    other.post demo_session_path(role: "agent")
    other.get ticket_path(foreign_ticket)
    other.assert_response :not_found
    other.post assign_ticket_path(foreign_ticket)
    other.assert_response :not_found
    other.get tickets_path
    other.assert_no_match "Sunum talebi", other.response.body
  end

  test "customer cannot access another customer in same workspace" do
    create_ticket
    other = @ticket.workspace.users.create!(name: "Diğer", email: "different@example.test", role: :customer)
    secret = @ticket.workspace.tickets.create!(customer: other, subject: "Başka müşteri", description: "Özel", first_response_due_at: 4.hours.from_now)
    get ticket_path(secret)
    assert_response :not_found
  end

  test "customer cannot inject status assignee or deadline through create" do
    sign_in("customer")
    post tickets_path, params: { ticket: { subject: "Manipülasyon", description: "Test", priority: "normal", status: "solved", first_response_due_at: 10.years.from_now, assignee_id: User.last.id } }
    ticket = Ticket.last
    assert ticket.new_ticket?
    assert_nil ticket.assignee_id
    assert_in_delta 4.hours.from_now.to_i, ticket.first_response_due_at.to_i, 2
  end

  test "invalid ticket renders useful errors without creating a record" do
    sign_in("customer")
    assert_no_difference "Ticket.count" do
      post tickets_path, params: { ticket: { subject: "", description: "", priority: "normal" } }
    end
    assert_response :unprocessable_entity
    assert_match "boş bırakılamaz", response.body
  end

  test "internal note form and public reply form are distinct and blank" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    post internal_note_ticket_path(@ticket), params: { body: "EKİP-ÖZELİ" }
    get ticket_path(@ticket)
    assert_select 'form[action=?] textarea', preview_reply_ticket_path(@ticket), text: ""
    assert_select 'form[action=?] textarea', internal_note_ticket_path(@ticket), text: ""
    assert_match "EKİP-ÖZELİ", response.body
  end

  test "queue filters show seeded deadline and followup examples" do
    sign_in("agent")
    get tickets_path(filter: "overdue")
    assert_response :success
    assert_match "Faturamı", response.body
    assert_select "tbody tr", count: 1
    get tickets_path(filter: "follow_up")
    assert_response :success
    assert_match "Dışa aktarılan", response.body
    assert_select "tbody tr", count: 1
  end

  test "anonymous users are redirected and role input is constrained" do
    get tickets_path
    assert_redirected_to root_path
    post "/demo/admin"
    assert_response :not_found
  end

  test "HTML in a message is escaped" do
    create_ticket
    sign_in("agent")
    post assign_ticket_path(@ticket)
    post preview_reply_ticket_path(@ticket), params: { body: '<script>alert("x")</script>Merhaba' }
    assert_response :success
    assert_select 'script', count: 0
  end
end
