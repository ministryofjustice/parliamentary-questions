require 'feature_helper'

def date
  PqStatistics::BUS_DAY_INTERVAL.business_days.before(Time.zone.today)
end

feature 'Statistics: PQs answered on time' do
  before(:each) do
    Timecop.freeze(Date.yesterday) do
      pqs = (1..6).to_a.map { FactoryBot.create(:answered_pq) }

      pqs.first(4).each do |pq|
        pq.update(
          date_for_answer: Time.zone.today,
          answer_submitted: Date.tomorrow,
          state: PQState::ANSWERED
        )
      end

      pqs.last(2).each do |pq|
        pq.update(
          date_for_answer: Time.zone.today,
          answer_submitted: Date.yesterday,
          state: PQState::ANSWERED
        )
      end
    end
  end

  scenario 'As a user I can see % of questions answered on time by date bucket' do
    create_pq_session
    visit '/statistics/on_time'

    expect(page).to have_content 'PQ Statistics: Answers'

    within "tr[data='bucket-" + date.to_s(:date) + "']" do
      expect(page).to have_content('33.33%')
      expect(page).to have_content('↑')
    end
  end

  scenario 'As a user I can retrieve % of questions answered on time by date bucket in JSON' do
    create_pq_session
    visit '/statistics/on_time.json'

    expect(page).to have_content(
      "{\"start_date\":\"#{date.to_s(:date)}\",\"data\":\"33.33%\",\"arrow\":\"↑\"}"
    )
  end
end

feature 'Statistics: Time to assign PQs' do
  before(:each) do
    Timecop.freeze(1.business_days.before(Time.zone.today)) do
      pqs = (1..4).to_a.map { FactoryBot.create(:not_responded_pq) }

      pqs.first(2).each do |pq|
        pq.update(
          created_at: 1.business_days.before(Time.zone.today)
        )
      end

      pqs.last(2).each do |pq|
        pq.update(
          created_at: 2.business_days.before(Time.zone.today)
        )
      end
    end
  end
end

feature 'Statistics: Time for AO response' do
  before(:each) do
    Timecop.freeze(1.business_days.before(Time.zone.today)) do
      pqs = (1..4).to_a.map { FactoryBot.create(:draft_pending_pq) }

      pqs.first(2).each do |pq|
        pq.action_officers_pqs.first.update(
          created_at: 2.business_days.before(Time.zone.today)
        )
      end
    end
  end
end

feature 'Statistics: AO churn' do
  before(:each) do
    ao  = FactoryBot.create(:action_officer)
    pqs = []

    Timecop.freeze(Date.yesterday) do
      pqs = (1..4).to_a.map { FactoryBot.create(:draft_pending_pq) }
    end

    (1..4).each do |n|
      Timecop.freeze(Date.yesterday - n.days) do
        pqs.last(2).each do |pq|
          ao_pq = ActionOfficersPq.create!(
            pq_id: pq.id,
            action_officer_id: ao.id
          )
          pq.action_officers_pqs << ao_pq
        end
      end
    end
  end
end

feature 'Statistics: Stages Time' do
  let(:base)      { 1.business_days.ago }
  let(:past_base) { 9.business_days.ago }

  before(:each) do
    pq1, pq2 = (1..2).map { FactoryBot.create(:answered_pq) }

    update_stage_times(pq1, [8, 6, 5, 2], base)
    update_stage_times(pq2, [12, 8, 5, 2], past_base)
  end

  def update_stage_times(pq, hours, base)
    pq.update(
      created_at: hours[0].business_hours.before(base),
      draft_answer_received: hours[1].business_hours.before(base),
      pod_clearance: hours[2].business_hours.before(base),
      cleared_by_answering_minister: hours[3].business_hours.before(base),
      answer_submitted: base
    )
  end
end
