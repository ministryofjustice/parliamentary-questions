# == Schema Information
#
# Table name: ministers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  title      :string(255)
#  deleted    :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  member_id  :integer
#

require "spec_helper"

describe Minister do
  subject(:minister) { create(:minister) }

  it { is_expected.to have_many(:pqs) }
  it { is_expected.to have_many(:minister_contacts) }
  it { is_expected.to accept_nested_attributes_for(:minister_contacts) }

  it "strips whitespace from name" do
    minister = create(:minister, name: "            person     ")
    expect(minister.name).to eql("person")
  end

  describe "#contact_emails" do
    let!(:minister_contact1) { create(:minister_contact, minister: subject) }
    let!(:minister_contact2) { create(:minister_contact, minister: subject) }
    let!(:deleted_minister_contact) { create(:deleted_minister_contact, minister: subject) }

    it "returns the active minister contacts emails" do
      expect(subject.contact_emails).to eql([
        minister_contact1.email,
        minister_contact2.email,
      ])
    end
  end

  describe "#name_with_inactive_status" do
    subject { minister.name_with_inactive_status }

    context "for active minister" do
      it "is the same as name" do
        expect(subject).to eql(minister.name)
      end
    end

    context "for deleted minister" do
      let(:minister) { create(:deleted_minister) }

      it "has the inactive suffix" do
        expect(subject).to eql(minister.name + " - Inactive")
      end
    end
  end

  describe ".active_or_having_id" do
    let(:minister)         { create(:minister) }
    let(:deleted_minister) { create(:deleted_minister) }

    it "returns only active ministers" do
      subject = Minister.active_or_having_id(nil)
      expect(subject).to eq [minister]
    end

    context "when explicitly including a minister" do
      let(:selected_minister) { create(:deleted_minister) }

      it "is included" do
        subject = Minister.active_or_having_id(selected_minister.id)
        expect(subject).to eq [selected_minister, minister]
      end
    end
  end

  describe "Get index" do
    let!(:minister1) { create(:minister, updated_at: DateTime.now.to_datetime, deleted: false) }
    let!(:minister2) { create(:minister, updated_at: DateTime.now.to_datetime, deleted: true) }
    let!(:minister3) { create(:minister, updated_at: 1.day.ago.to_datetime,    deleted: false) }
    let!(:minister4) { create(:minister, updated_at: 1.day.ago.to_datetime,    deleted: true) }
    let!(:minister5) { create(:minister, updated_at: 3.days.ago.to_datetime,   deleted: false) }
    let!(:minister6) { create(:minister, updated_at: 3.days.ago.to_datetime,   deleted: true) }

    it "lists all active Ministers and those made inactive withing the last two days" do
      expect(Minister.active_list).to match_array [minister1, minister2, minister3, minister4, minister5]
    end
  end
end
