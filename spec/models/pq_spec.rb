require 'spec_helper'

describe Pq do
	let(:newQ) {build(:Pq)}

  describe '#commissioned?' do
    subject(:pq) { create(:Pq)}
    subject { pq.commissioned? }

    context 'when no officer is assigned' do
      it { should be false}
    end

    context 'when all assigned officers are rejected' do
      before do
        pq.action_officers_pq.create(action_officer: create(:action_officer), reject: true)
      end

      it { should be false}
    end

    context 'when some assigned officers are not rejected' do
      before do
        pq.action_officers_pq.create(action_officer: create(:action_officer))
        pq.action_officers_pq.create(action_officer: create(:action_officer), reject: true)
      end

      it { should be true}
    end
  end

  describe '#closed?' do
    subject { pq.closed? }

    context 'for unanswered question' do
      let(:pq) { create(:Pq) }
      it { should be false }
    end

    context 'for answered question' do
      let(:pq) { create(:answered_pq) }
      it { should be true }
    end
  end

  it 'should set pod_waiting when users set draft_answer_received' do
    expect(newQ).to receive(:set_pod_waiting)
    newQ.update(draft_answer_received: Date.new(2014,9,4))
    newQ.save
  end

  it '#set_pod_waiting should work as expected' do
    expect(newQ.draft_answer_received).to be_nil
    expect(newQ.pod_waiting).to be_nil
    dar = Date.new(2014,9,4)
    newQ.draft_answer_received = dar
    newQ.set_pod_waiting
    expect(newQ.pod_waiting).to eq(dar)
  end

	describe 'validation' do

		it 'should pass onfactory build' do
			expect(newQ).to be_valid
		end
		it 'should have a Uin' do
			newQ.uin=nil
			expect(newQ).to be_invalid
		end
		it 'should have a Raising MP ID' do
			newQ.raising_member_id=nil
			expect(newQ).to be_invalid
		end
		it 'should have text' do
			newQ.question=nil
			expect(newQ).to be_invalid
		end
		xit 'should not allow finance interest to be set if it has not been seen by finance' do
			newQ.seen_by_finance=true
			expect(newQ).to be_invalid
			newQ.finance_interest=true
			expect(newQ).to be_valid
			newQ.finance_interest=false
			expect(newQ).to be_valid
    end
    it 'should strip any whitespace from uins' do
      newQ.update(uin: ' hl1234' )
      expect(newQ).to be_valid
      expect(newQ.uin).to eql('hl1234')
      newQ.update(uin: 'hl1234 ' )
      expect(newQ).to be_valid
      expect(newQ.uin).to eql('hl1234')
      newQ.update(uin: ' hl1 234' )
      expect(newQ).to be_valid
      expect(newQ.uin).to eql('hl1234')
    end

	end
	describe 'item' do
		it 'should allow finance interest to be set' do
			newQ.finance_interest=true
			expect(newQ).to be_valid
			newQ.finance_interest=false
			expect(newQ).to be_valid
		end
	end
	describe "associations" do
		it 'should allow minister to be set' do
			@minister = newQ.should respond_to(:minister)
		end		
		it 'should allow policy minister to be set' do
			@pminister = newQ.should respond_to(:policy_minister)
		end
		it 'should have a collection of trim links' do
			@trim = newQ.should respond_to(:trim_links)
		end
	end
end
