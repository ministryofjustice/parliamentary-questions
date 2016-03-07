module RakeTaskHelpers
  class DBSanitizer

    MY_SQLS =
    [
      "update action_officers    set email ='pqsupport+ao' || id || '@digital.justice.gov.uk'",
      "update actionlist_members set email ='pqsupport+alm' || id || '@digital.justice.gov.uk'",
      "update deputy_directors   set email ='pqsupport+dd' || id || '@digital.justice.gov.uk'",
      "update minister_contacts  set email ='pqsupport+mc' || id || '@digital.justice.gov.uk'",
      "update press_officers     set email ='pqsupport+po' || id || '@digital.justice.gov.uk'",
      "update users              set email ='pqsupport+u' || id || '@digital.justice.gov.uk'",
      "update watchlist_members  set email ='pqsupport+wlm' || id || '@digital.justice.gov.uk'",
      "update early_bird_members set email ='pqsupport+ebm' || id || '@digital.justice.gov.uk'",
      "update action_officers    set group_email ='pqsupport+gm' || id || '@digital.justice.gov.uk'"
    ]

    def run!
      MY_SQLS.map do |sql|
        ActiveRecord::Base.connection.execute sql
      end
    end
  end
end
