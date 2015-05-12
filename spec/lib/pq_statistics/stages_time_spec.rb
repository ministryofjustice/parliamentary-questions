require 'spec_helper'
require 'business_time'

describe PqStatistics::StagesTime do  
  context '#calculate' do
    
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