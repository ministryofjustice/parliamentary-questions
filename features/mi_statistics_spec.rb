require 'feature_helper'

def date
  PqStatistics::BUS_DAY_INTERVAL.business_days.before(Date.today)
end

feature 'Statistics: PQs answered on time' do
  before(:each) do
    Timecop.freeze(Date.yesterday) do
      pqs = (1..6).to_a.map{ FactoryGirl.create(:answered_pq) }

      pqs.first(4).each do |pq| 
        pq.update(
          date_for_answer:  Date.today, 
          answer_submitted: Date.tomorrow,
          state:            PQState::ANSWERED
        )
      end

      pqs.last(2).each do |pq| 
        pq.update(
          date_for_answer:  Date.today, 
          answer_submitted: Date.yesterday,
          state:            PQState::ANSWERED
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
    Timecop.freeze(1.business_days.before(Date.today)) do
      pqs = (1..4).to_a.map{ FactoryGirl.create(:not_responded_pq) }

      pqs.first(2).each do |pq| 
        pq.update(
          created_at: 1.business_days.before(Date.today)
        )
      end

      pqs.last(2).each do |pq| 
        pq.update(
          created_at: 2.business_days.before(Date.today)
        )
      end
    end
  end

  scenario 'As a user I can view the average hours to assignment of PQs by date' do
    create_pq_session
    visit '/statistics/time_to_assign'

    expect(page).to have_content 'PQ Statistics: Assignment'

    within "tr[data='bucket-" + date.to_s(:date) + "']" do
      expect(page).to have_content('15.0')
      expect(page).to have_content('↑')
    end
  end

  scenario 'As a user I can retrieve the average hours to assignment of PQs by date in JSON' do
    create_pq_session
    visit '/statistics/time_to_assign.json'

    expect(page).to have_content(
      "{\"start_date\":\"#{date.to_s(:date)}\",\"data\":\"15.0\",\"arrow\":\"↑\"}"
    )
  end
end

feature 'Statistics: Time for AO response' do
  before(:each) do
    Timecop.freeze(1.business_days.before(Date.today)) do
      pqs = (1..4).to_a.map{ FactoryGirl.create(:draft_pending_pq) }

      pqs.first(2).each do |pq| 
        pq.action_officers_pqs.first.update(
          created_at: 2.business_days.before(Date.today)
        )
      end
    end
  end

  scenario 'As a user I can view the average hours an AO takes to accept/reject a PQ' do
    create_pq_session
    visit '/statistics/ao_response_time'

    expect(page).to have_content 'PQ Statistics: Action Officer response'

    within "tr[data='bucket-" + date.to_s(:date) + "']" do
      expect(page).to have_content('10.0')
      expect(page).to have_content('↑')
    end
  end

  scenario 'As a user I can retrieve the average hours an AO takes to accept/reject a PQ in JSON' do
    create_pq_session
    visit '/statistics/ao_response_time.json'

    expect(page).to have_content(
      "{\"start_date\":\"#{date.to_s(:date)}\",\"data\":\"10.0\",\"arrow\":\"↑\"}"
    )
  end
end

feature 'Statistics: AO churn' do
  before(:each) do
    ao  = FactoryGirl.create(:action_officer) 
    pqs = []

    Timecop.freeze(Date.yesterday) do
     pqs = (1..4).to_a.map{ FactoryGirl.create(:draft_pending_pq) }
    end

    (1..4).each do |n|
     Timecop.freeze(Date.yesterday - n.days) do
       pqs.last(2).each do |pq| 
         ao_pq =  ActionOfficersPq.create!(
                   pq_id: pq.id,
                   action_officer_id: ao.id
                 )
         pq.action_officers_pqs << ao_pq
       end
     end
    end
  end

  scenario 'As a user I can view the average number of times a PQ is reassigned to different AOs' do
    create_pq_session
    visit '/statistics/ao_churn'


    expect(page).to have_content 'PQ Statistics: Action Officer churn'

    within "tr[data='bucket-" + date.to_s(:date) + "']" do
      expect(page).to have_content('2.00')
      expect(page).to have_content('↑')
    end
  end

  scenario 'As a user I can retrieve the average number of times a PQ is reassigned to different AOs in JSON' do
    create_pq_session
    visit '/statistics/ao_churn.json'

    expect(page).to have_content(
      "{\"start_date\":\"#{date.to_s(:date)}\",\"data\":\"2.00\",\"arrow\":\"↑\"}"
    )
  end
end

feature 'Statistics: Stages Time' do
  let(:base)      { 1.business_days.ago }
  let(:past_base) { 9.business_days.ago }

  before(:each) do
    pq1, pq2 = (1..2).map{ FactoryGirl.create(:answered_pq) } 

    update_stage_times(pq1, [8, 6, 5, 2], base)
    update_stage_times(pq2, [12, 8, 5, 2], past_base)
  end

  def update_stage_times(pq, hours, base)
    pq.update(
      created_at:                    hours[0].business_hours.before(base),      
      draft_answer_received:         hours[1].business_hours.before(base),   
      pod_clearance:                 hours[2].business_hours.before(base),   
      cleared_by_answering_minister: hours[3].business_hours.before(base), 
      answer_submitted:              base
    )
  end

  scenario 'As a user I can retrieve the average time taken at each stage of the PQ process in JSON' do
    create_pq_session
    visit '/statistics/stages_time.json'

    expect(page).to have_content(
      "{\"title\":\"PQ Statistics: stages time\"," +
      "\"current_journey\":[{\"name\":\"Draft Answer\",\"time\":\"2.0\"},{\"name\":\"POD Clearance\",\"time\":\"1.0\"}," +
      "{\"name\":\"Minister Clearance\",\"time\":\"3.0\"},{\"name\":\"Submit Answer\",\"time\":\"2.0\"}]," + 
      "\"benchmark_journey\":[{\"name\":\"Draft Answer\",\"time\":\"3.0\"},{\"name\":\"POD Clearance\",\"time\":\"2.0\"}," + 
      "{\"name\":\"Minister Clearance\",\"time\":\"3.0\"},{\"name\":\"Submit Answer\",\"time\":\"2.0\"}]}"
    )
  end
end