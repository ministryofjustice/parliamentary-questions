# This module contains constants for use in metrics generation to allow the naming 
# convention to be managed centrally

module StatsHelper

  METRIC_DASHBOARD_HITS = "dashboard.hits"

  MAIL_TIMING   = "mails.timing"
  MAIL_SUCCESS  = "mails.success"
  MAIL_FAILURE  = "mails.failed"


  PAGES_TIMING   = "pages.timing"
  PAGES_ERRORS   = "pages.errors"

  TOKENS_GENERATE = "tokens.generate"
  TOKENS_VALID = "tokens.validation.valid"
  TOKENS_INVALID = "tokens.validation.valid"


  IMPORT = "questions.import"
  PROGRESS = "questions.progress"

end
