require 'spec_helper'

RSpec.describe ApplicationHelper do
  describe '#minister_warning?' do
    it 'false when no question' do
      expect(helper.minister_warning?(nil, nil)).to be false
    end

    it 'false when not open' do
      question = create(:question_answered)
      expect(helper.minister_warning?(question, nil)).to be false
    end

    it 'false when no minister' do
      question = build(:question)
      minister = nil
      expect(helper.minister_warning?(question, minister)).to be nil
    end

    it 'false when minister not deleted' do
      question = build(:question)
      minister = build(:minister)
      expect(helper.minister_warning?(question, minister)).to be false
    end

    it 'true when minister deleted' do
      question = build(:question)
      minister = build(:deleted_minister)
      expect(helper.minister_warning?(question, minister)).to be true
    end
  end

  describe '#ministers' do
    let(:minister) { double }
    let(:question) { double minister: minister }
    before { expect(Minister).to receive(:active).with(minister) }

    it 'returns active ministers including selected' do
      helper.ministers(question)
    end
  end

  describe '#policy_ministers' do
    let(:minister) { double }
    let(:question) { double policy_minister: minister }
    before { expect(Minister).to receive(:active).with(minister) }

    it 'returns active ministers including selected' do
      helper.policy_ministers(question)
    end
  end
end
