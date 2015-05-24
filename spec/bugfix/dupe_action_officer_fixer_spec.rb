require 'spec_helper'

describe DupeActionOfficerFixer do 

  before(:each) do
    @ao1_old = FactoryGirl.create(:action_officer, name: 'Orig Action Officer 1', deleted: true)
    @ao2_old = FactoryGirl.create(:action_officer, name: 'Orig Action Officer 2', deleted: true)
    @ao3_old = FactoryGirl.create(:action_officer, name: 'Orig Action Officer 3', deleted: true)
    @ao1_new = FactoryGirl.create(:action_officer, name: 'New Action Officer 1', deleted: false)
    @ao2_new = FactoryGirl.create(:action_officer, name: 'New Action Officer 2', deleted: false)
    @ao3_new = FactoryGirl.create(:action_officer, name: 'New Action Officer 3', deleted: false)

    @pq1 = FactoryGirl.create :pq, uin: 'UIN0001', question: "This is question 1"
    @pq2 = FactoryGirl.create :pq, uin: 'UIN0002',  question: "This is question 2"
    @pq3 = FactoryGirl.create :pq, uin: 'UIN0003',  question: "This is question 3"
    
    @pq1.action_officers = [ @ao1_old, @ao2_old, @ao3_old ]
    @pq2.action_officers = [ @ao1_old, @ao2_new, @ao3_old ]
    @pq3.action_officers = [ @ao1_new, @ao2_new, @ao3_new ]

    @dupes = { @ao1_old.id => @ao1_new.id, @ao2_old.id => @ao2_new.id, @ao3_old.id => @ao3_new.id }
    @fixer = DupeActionOfficerFixer.new( @dupes )
  end

  
  describe 'find all ao_pqs relating to an action_officers that are to be replaced' do
    it 'should return a list of ao_pqs' do
      expect(ActionOfficersPq.count).to eq 9

      aopqs = @fixer.send(:find_aopqs)

      expect(aopqs.size).to eq 5
      expect(aopqs.map(&:pq_id).uniq.sort).to eq( [@pq1.id, @pq2.id])
      expect(aopqs.select{|r| r.pq_id == @pq1.id}.size).to eq 3
      expect(aopqs.select{|r| r.pq_id == @pq2.id}.size).to eq 2
    end
  end

  describe 'dedupe' do
    it 'should replace all old ao_ids with new' do
      @fixer.dedupe!
      pq1 = Pq.find @pq1.id
      pq2 = Pq.find @pq2.id
      pq3 = Pq.find @pq3.id
      expect(pq1.action_officers.map(&:id).sort).to eq ( [ @ao1_new.id, @ao2_new.id, @ao3_new.id ])
      expect(pq2.action_officers.map(&:id).sort).to eq ( [ @ao1_new.id, @ao2_new.id, @ao3_new.id ])
      expect(pq1.action_officers.map(&:id).sort).to eq ( [ @ao1_new.id, @ao2_new.id, @ao3_new.id])
    end

    it 'should report on what it has changed' do
      @fixer.dedupe!
      expect(@fixer.instance_variable_get(:@report)).to eq(
        [
          "PQ UIN0001 AO #{@ao1_old.id}:Orig Action Officer 1 replaced with AO #{@ao1_new.id}:New Action Officer 1.",
          "PQ UIN0001 AO #{@ao2_old.id}:Orig Action Officer 2 replaced with AO #{@ao2_new.id}:New Action Officer 2.",
          "PQ UIN0001 AO #{@ao3_old.id}:Orig Action Officer 3 replaced with AO #{@ao3_new.id}:New Action Officer 3.",
          "PQ UIN0002 AO #{@ao1_old.id}:Orig Action Officer 1 replaced with AO #{@ao1_new.id}:New Action Officer 1.",
          "PQ UIN0002 AO #{@ao3_old.id}:Orig Action Officer 3 replaced with AO #{@ao3_new.id}:New Action Officer 3."
        ])
    end
  end




end



