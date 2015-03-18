require 'spec_helper'

RSpec.describe ApplicationHelper do
  describe '#minister_warning?' do
    it 'false when no question' do
      expect(helper.minister_warning?(nil, nil)).to be false
    end

    it 'false when not open' do
      question = build(:answered_pq)
      expect(helper.minister_warning?(question, nil)).to be false
    end

    it 'false when no minister' do
      question = build(:pq)
      minister = nil
      expect(helper.minister_warning?(question, minister)).to be nil
    end

    it 'false when minister not deleted' do
      question = build(:pq)
      minister = build(:minister)
      expect(helper.minister_warning?(question, minister)).to be false
    end

    it 'true when minister deleted' do
      question = build(:pq)
      minister = build(:deleted_minister)
      expect(helper.minister_warning?(question, minister)).to be true
    end
  end
end
