require 'Business_time'
module PQA
  module RecentQuestionsURL
    def self.url(this_day)
      previous_day = 1.business_days.before(this_day)
      url = "http://www.parliament.uk/business/publications/written-questions-answers-statements/written-questions-answers/?page=1&max=20&questiontype=QuestionsOnly&house=commons%2clords&use-dates=True&answered-from=#{previous_day}&answered-to=#{this_day}"
    end
  end
end
