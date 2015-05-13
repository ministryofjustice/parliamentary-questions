require 'spec_helper'
require 'business_time'

describe PqStatistics::StagesTime do  
  let(:base)      { 1.business_days.ago }
  let(:past_base) { 9.business_days.ago }

  before(:each) do
    pq1, pq2, pq3, pq4 = (1..4).map{ FactoryGirl.create(:answered_pq) } 

    update_stage_times(pq1, [8, 6, 5, 2], base)
    update_stage_times(pq2, [12, 8, 5, 2], base)

    update_stage_times(pq3, [13, 7, 2, 1], past_base)
    update_stage_times(pq4, [6, 5, 1, 0], past_base)
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

  describe '#calculate' do
    it 'should return the 5 day and 30 days journey results' do
      short = double PqStatistics::StagesTime::Journey
      long  = double PqStatistics::StagesTime::Journey

      expect(PqStatistics::StagesTime).to receive(:calculate_5_day).and_return(short)
      expect(PqStatistics::StagesTime).to receive(:calculate_30_day).and_return(long)

      expect(PqStatistics::StagesTime.calculate).to eq ([short, long])
    end
  end

  describe '#calculate_5_day' do
    it 'should return the average time for each stage of pqs created over the past 5 days' do
      result = 
        PqStatistics::StagesTime.calculate_5_day
          .stages
          .map(&:average_time)
          .map{|i| i.round(-1) }

      expect(result).to eq(
        [3, 2, 3, 2]
          .map{ |hours| hours * 3600 }
      )
    end
  end

  describe '#calculate_30_day' do
    it 'should return the average time for each stage of pqs created over the past 30 days' do
      result = 
        PqStatistics::StagesTime.calculate_30_day
          .stages
          .map(&:average_time)
          .map{|i| i.round(-1) }

      expect(result).to eq(
        [3.25, 3.25, 2, 1.25]
          .map{ |hours| hours * 3600 }
      )
    end
  end
end

describe PqStatistics::StagesTime::Journey do
  let(:pq) { double Pq }

  it '#update - calls update on each of the stages of the journey' do
    expect_any_instance_of(PqStatistics::StagesTime::DraftAnswer)
      .to receive(:update).with(pq)
    expect_any_instance_of(PqStatistics::StagesTime::PodClearance)
      .to receive(:update).with(pq)
    expect_any_instance_of(PqStatistics::StagesTime::MinisterClearance)
      .to receive(:update).with(pq)
    expect_any_instance_of(PqStatistics::StagesTime::SubmitAnswer)
      .to receive(:update).with(pq)

    subject.update(pq)
  end
end

describe PqStatistics::StagesTime::Stage do  
  let(:now) { DateTime.now }

  describe 'Draft Answer' do
    let(:stage) { PqStatistics::StagesTime::DraftAnswer.new }

    let(:pq)  { 
      double Pq, 
      created_at: 1.business_days.before(now), 
      draft_answer_received: now
    }

    it '#initialize - should create a draft answer stage' do
      expect(stage.name).to eq 'Draft Answer'
      expect(stage.average_time).to eq 0.0
    end

    it '#update - should increment the stage duration and count' do
      stage.update(pq)

      expect(stage.average_time).to be_within(1).of(36000)
    end
  end

  describe 'Pod Clearance' do
    let(:stage) { PqStatistics::StagesTime::PodClearance.new }

    let(:pq)  { 
      double Pq, 
      draft_answer_received: 2.business_days.before(now), 
      pod_clearance: now
    }

    it '#initialize - should create a pod clearance stage' do
      expect(stage.name).to eq 'POD Clearance'
      expect(stage.average_time).to eq 0.0
    end

    it '#update - should increment the stage duration and count' do
      stage.update(pq)

      expect(stage.average_time).to be_within(1).of(72000)
    end
  end

  describe 'Minister Clearance' do
    let(:stage) { PqStatistics::StagesTime::MinisterClearance.new }

    let(:pq)  { 
      double Pq, 
      policy_minister: nil,
      cleared_by_answering_minister: now,
      pod_clearance: 1.business_days.before(now)
    }

    it '#initialize - should create a pod clearance stage' do
      expect(stage.name).to eq 'Minister Clearance'
      expect(stage.average_time).to eq 0.0
    end

    it '#update - should increment the stage duration and count' do
      stage.update(pq)

      expect(stage.average_time).to be_within(1).of(36000)
    end
  end
  
  describe 'Submit Answer' do
    let(:stage) { PqStatistics::StagesTime::SubmitAnswer.new }

    let(:pq)  { 
      double Pq, 
      policy_minister: 'a minister',
      cleared_by_policy_minister: 1.business_days.before(now),
      cleared_by_answering_minister: 2.business_days.before(now),
      answer_submitted: now
    }

    it '#initialize - should create a pod clearance stage' do
      expect(stage.name).to eq 'Submit Answer'
      expect(stage.average_time).to eq 0.0
    end

    it '#update - should increment the stage duration and count' do
      stage.update(pq)

      expect(stage.average_time).to be_within(1).of(36000)
    end
  end
end