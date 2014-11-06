require 'spec_helper'

describe Pq do
	let(:newQ) {build(:pq)}

	describe "associations" do
		it { is_expected.to belong_to :minister }
		it { is_expected.to belong_to :policy_minister }
		it { is_expected.to have_many :trim_links }
	end

	describe "associations" do
		it { is_expected.to belong_to :minister }
		it { is_expected.to belong_to :policy_minister }
		it { is_expected.to have_many :trim_links }
	end

  describe 'allocated_since' do
    let!(:older_pq) { create(:not_responded_pq, action_officer_allocated_at: Time.now - 2.days)}
    let!(:new_pq1) { create(:not_responded_pq, uin: '20001', action_officer_allocated_at: Time.now + 3.hours)}
    let!(:new_pq2) { create(:not_responded_pq, uin: 'HL01',  action_officer_allocated_at: Time.now + 5.hours)}
    let!(:new_pq3) { create(:not_responded_pq, uin: '15000', action_officer_allocated_at: Time.now + 5.hours)}

    subject { Pq.allocated_since(Time.now) }

    it 'returns questions allocated from given time' do
      expect(subject.length).to be(3)
    end

    it 'returns questions ordered by uin' do
      expect(subject.map(&:uin)).to eql(%w(15000 20001 HL01))
    end
  end

  describe '#commissioned?' do
    subject(:pq) { create(:pq)}
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
		it 'is closed when answered' do
			subject = build(:answered_pq)
			expect(subject.closed?).to be true
		end

		it 'is not closed when unanswered' do
			subject = build(:pq)
			expect(subject.closed?).to be false
		end
	end

	describe '#open?' do
		it 'open when unanswered' do
			subject = build(:pq)
		  expect(subject.open?).to be true
		end

		it 'not open when answered' do
		  subject = build(:answered_pq)
			expect(subject.open?).to be false
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
end
