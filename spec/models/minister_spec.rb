require 'spec_helper'

describe Minister do
  subject { create(:minister) }

  it { should have_many(:pqs) }
  it { should have_many(:minister_contacts) }

  it { should accept_nested_attributes_for(:minister_contacts)}

  it 'should strip whitespace from name' do
    minister = create(:minister, name: '            person     ')
    expect(minister.name).to eql('person')
  end

  describe '#email' do
    let!(:minister_contact1) { create(:minister_contact, minister: subject) }
    let!(:minister_contact2) { create(:minister_contact, minister: subject) }
    let!(:deleted_minister_contact) { create(:deleted_minister_contact, minister: subject) }

    it 'returns active minister contacts emails joined with ;' do
      expect(subject.email).to eql("#{minister_contact1.email};#{minister_contact2.email}")
    end
  end

  describe '::all_active' do
    let!(:minister) { create(:minister) }
    let!(:deleted_minister) { create(:deleted_minister) }
    subject { Minister.all_active }

    it 'returns only active ministers' do
      expect(subject).to include(minister)
    end
    it 'includes all active ministers' do
      expect(subject.size).to eql(1)
    end
  end
end
