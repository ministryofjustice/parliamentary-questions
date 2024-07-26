require "rails_helper"
require "business_time"

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
