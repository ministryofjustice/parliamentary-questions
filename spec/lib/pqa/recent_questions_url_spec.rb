require "spec_helper"
require "business_time"

before do
  "http://www.parliament.uk/business/publications/written-questions-answers-statements/written-questions-answers/?page=1&max=20&questiontype=QuestionsOnly&house=commons%2clords&use-dates=True&answered-from=2015-01-01&answered-to=2015-07-28"
end

describe "geturl" do
  it "gives Friday-Monday url on a Monday" do
    this_day = Time.zone.today.beginning_of_week
    previous_day = 1.business_days.before(this_day)
    url = PQA::RecentQuestionsUrl.url(this_day)
    expect(url).to include(this_day.strftime("%F"))
    expect(url).to include(previous_day.strftime("%F"))
  end

  it "gives Monday-Tuesday url on a Tuesday" do
    this_day = Time.zone.today.beginning_of_week + 1
    previous_day = 1.business_days.before(this_day)
    url = PQA::RecentQuestionsUrl.url(this_day)
    expect(url).to include(this_day.strftime("%F"))
    expect(url).to include(previous_day.strftime("%F"))
  end
end
