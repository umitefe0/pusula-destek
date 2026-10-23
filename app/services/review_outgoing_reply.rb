class ReviewOutgoingReply
  # Workspace locking serializes quota reservation without holding a lock during HTTP.
  # The global count is a best-effort demo cap: concurrent workspaces can overshoot.
  def self.call(ticket:, author:, body:, guard: ContentGuard.new)
    raise TicketWorkflow::NotAuthorized unless author.agent? && author.workspace_id == ticket.workspace_id
    review = nil
    ticket.workspace.with_lock do
      local_count = ReplyReview.joins(:ticket).where(tickets: { workspace_id: ticket.workspace_id }).where(created_at: 1.hour.ago..).count
      global_count = ReplyReview.where(created_at: 24.hours.ago..).count
      limited = local_count >= 30 || global_count >= ENV.fetch("GROQ_DAILY_LIMIT", "300").to_i
      review = ReplyReview.create!(ticket:, author:, body_digest: Digest::SHA256.hexdigest(body),
        status: limited ? "unavailable" : "checking", category: "uncertain",
        reason: limited ? "Demo kontrol limiti doldu. Daha sonra yeniden deneyin; gönderim kapalı." : "Kontrol sürüyor.",
        model: ENV.fetch("GROQ_MODEL", "openai/gpt-oss-20b"), expires_at: 15.minutes.from_now)
    end
    return review unless review.status_checking?
    result = guard.call(body)
    review.update!(result.to_h.merge(expires_at: 15.minutes.from_now))
    review
  end
end
