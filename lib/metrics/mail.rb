module Metrics
  class Mail < Component
    attr_reader :num_waiting, 
                :num_abandoned, 
                :num_unanswered_tokens,
                :pctg_answered_tokens

    def collect!
      @num_waiting           = Email.waiting.size
      @num_abandoned         = Email.abandoned.size
      @num_unanswered_tokens = Token.assignment_stats[:open]
      @pctg_answered_tokens  = Token.assignment_stats[:pctg]
    end

    def email_error?
      num_waiting >= Settings.gecko_warning_levels.num_emails_waiting || 
        num_abandoned >= Settings.gecko_warning_levels.num_emails_abandoned
    end

    def token_error?
      pctg_answered_tokens < Settings.gecko_warning_levels.pctg_answered_tokens
    end
  end
end