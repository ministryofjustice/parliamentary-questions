require "feature_helper"

def date
  PqStatistics::BUS_DAY_INTERVAL.business_days.before(Time.zone.today)
end

describe "Statistics: PQs answered on time" do
  before do
    Timecop.freeze(Date.yesterday) do
      pqs = (1..6).to_a.map { FactoryBot.create(:answered_pq) }

      pqs.first(4).each do |pq|
        pq.update(
          date_for_answer: Time.zone.today,
          answer_submitted: Date.tomorrow,
          state: PQState::ANSWERED,
        )
      end

      pqs.last(2).each do |pq|
        pq.update(
          date_for_answer: Time.zone.today,
          answer_submitted: Date.yesterday,
          state: PQState::ANSWERED,
        )
      end
    end
  end

  it "As a user I can see % of questions answered on time by date bucket" do
    create_pq_session
    visit "/statistics/on_time"

    expect(page).to have_content "PQ Statistics: Answers"

    within "tr[data='bucket-#{date.to_s(:date)}']" do
      expect(page).to have_content("33.33%")
      expect(page).to have_content("↑")
    end
  end

  it "As a user I can retrieve % of questions answered on time by date bucket in JSON" do
    create_pq_session
    visit "/statistics/on_time.json"

    expect(page).to have_content(
      "{\"start_date\":\"#{date.to_s(:date)}\",\"data\":\"33.33%\",\"arrow\":\"↑\"}",
    )
  end
end
