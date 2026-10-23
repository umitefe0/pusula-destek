require "test_helper"

class ContentGuardTest < ActiveSupport::TestCase
  def response_for(status: "safe", category: "customer_ready", reason: "Müşteriye uygun.", finish: "stop")
    { "choices" => [{ "finish_reason" => finish, "message" => { "content" => JSON.generate({ status:, category:, reason: }) } }] }
  end

  test "structured provider response is parsed and only the draft is transmitted" do
    sent = nil
    guard = ContentGuard.new(api_key: "test-key", transport: ->(payload) { sent = payload; response_for })
    result = guard.call("Ödeme sorununuzu inceliyoruz.")
    assert_equal "safe", result.status
    assert_equal ["system", "user"], sent[:messages].map { |m| m[:role] }
    assert_equal "Ödeme sorununuzu inceliyoruz.", sent[:messages].last[:content]
    assert_equal true, sent.dig(:response_format, :json_schema, :strict)
    assert_equal "openai/gpt-oss-20b", result.model
  end

  test "blocked and uncertain decisions retain their meaning" do
    [["blocked", "internal_information"], ["uncertain", "uncertain"]].each do |status, category|
      guard = ContentGuard.new(api_key: "test", transport: ->(_) { response_for(status:, category:) })
      assert_equal status, guard.call("sentetik taslak").status
    end
  end

  test "missing credentials never invoke transport or approve" do
    guard = ContentGuard.new(api_key: "", transport: ->(_) { flunk "No request without key" })
    assert_equal "unavailable", guard.call("Merhaba").status
  end

  test "malformed truncated refused and contradictory results fail closed" do
    samples = [nil, {}, { "choices" => [] }, response_for(finish: "length"),
      response_for(status: "safe", category: "credentials"), response_for(reason: ""),
      response_for(status: "approve"), { "choices" => [{ "finish_reason" => "stop", "message" => { "content" => "not JSON" } }] },
      { "choices" => [{ "finish_reason" => "stop", "message" => { "refusal" => "refused", "content" => "{}" } }] }]
    samples.each do |response|
      guard = ContentGuard.new(api_key: "test", transport: ->(_) { response })
      assert_equal "unavailable", guard.call("Merhaba").status
    end
  end

  test "network timeout fails closed" do
    guard = ContentGuard.new(api_key: "test", transport: ->(_) { raise Net::ReadTimeout })
    assert_equal "unavailable", guard.call("Merhaba").status
  end

  test "HTTP authentication rate limit and server failures never approve" do
    %w[401 429 500].each do |code|
      response = Net::HTTPResponse.new("1.1", code, "Error")
      response.body = "provider error"
      http = Object.new
      %i[use_ssl= open_timeout= read_timeout= write_timeout= max_retries=].each do |setting|
        http.define_singleton_method(setting) { |_| }
      end
      http.define_singleton_method(:request) { |_| response }
      Net::HTTP.stub(:new, http) do
        assert_equal "unavailable", ContentGuard.new(api_key: "test-key").call("Merhaba").status
      end
    end
  end

  test "real adapter sends authorized JSON to fixed HTTPS endpoint" do
    sent = nil
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.body = JSON.generate(response_for)
    response.instance_variable_set(:@read, true)
    http = Object.new
    %i[use_ssl= open_timeout= read_timeout= write_timeout= max_retries=].each do |setting|
      http.define_singleton_method(setting) { |_| }
    end
    http.define_singleton_method(:request) { |request| sent = request; response }
    Net::HTTP.stub(:new, http) do
      assert_equal "safe", ContentGuard.new(api_key: "fake-unit-test-key").call("Merhaba").status
    end
    assert_equal "Bearer fake-unit-test-key", sent["Authorization"]
    assert_equal "/openai/v1/chat/completions", sent.path
    assert_equal "Merhaba", JSON.parse(sent.body).fetch("messages").last.fetch("content")
  end
end
