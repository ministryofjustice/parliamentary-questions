require 'Business_time'
#Used by earlybird - Please leave this comment to enable find (As PQA is the right module for parliament interface, but mau not be immediately obvious for dev looking at early bird)
module PQA
  module RecentQuestionsURL
    def self.url(this_day)
      previous_day = 1.business_days.before(this_day)
      str_this_day = this_day.strftime("%F")
      str_previous_day = previous_day.strftime("%F")
      url = "http://www.parliament.uk/business/publications/written-questions-answers-statements/written-questions-answers/?page=1&max=20&questiontype=QuestionsOnly&house=commons%2clords&use-dates=True&answered-from=#{str_previous_day}&answered-to=#{str_this_day}"
    end
  end
end
