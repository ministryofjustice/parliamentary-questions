require 'spec_helper'

describe Minister do
  subject(:minister) { create(:minister) }

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

  describe '#name_with_inactive_status' do
    subject { minister.name_with_inactive_status }

    context 'for active minister' do
      it 'should be the same as name' do
        is_expected.to eql(minister.name)
      end
    end

    context 'for deleted minister' do
      let(:minister) { create(:deleted_minister)}
      it 'should have the inactive suffix' do
        is_expected.to eql(minister.name + ' - Inactive')
      end
    end
  end

  describe '.active' do
    let(:minister) { create(:minister) }
    let(:deleted_minister) { create(:deleted_minister) }

    it 'returns only active ministers' do
      subject = Minister.active
      expect(subject).to eq [minister]
    end

    context 'when explicitly including a minister' do
      let(:selected_minister) { create(:deleted_minister) }

      it 'is included' do
        subject = Minister.active(selected_minister)
        expect(subject).to eq [selected_minister, minister]
      end
    end
  end
end
