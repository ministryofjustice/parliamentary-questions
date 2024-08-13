# == Schema Information
#
# Table name: ministers
#
#  id         :integer          not null, primary key
#  name       :string
#  title      :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  member_id  :integer
#

require "rails_helper"

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
    let!(:minister_contact_first) { create(:minister_contact, minister: subject) }
    let!(:minister_contact_second) { create(:minister_contact, minister: subject) }

    it "returns the active minister contacts emails" do
      expect(minister.contact_emails).to eql([
        minister_contact_first.email,
        minister_contact_second.email,
      ])
    end
  end

  describe "#name_with_inactive_status" do
    subject(:name) { minister.name_with_inactive_status }

    context "when the active minister" do
      it "is the same as name" do
        expect(name).to eql(minister.name)
      end
    end

    context "when the minister had been deleted" do
      let(:minister) { create(:deleted_minister) }

      it "has the inactive suffix" do
        expect(name).to eql("#{minister.name} - Inactive")
      end
    end
  end

  describe ".active_or_having_id" do
    let(:minister) { create(:minister) }
    let(:deleted_minister) { create(:deleted_minister) }

    it "returns only active ministers" do
      subject = described_class.active_or_having_id(nil)
      expect(subject).to eq [minister]
    end

    context "when explicitly including a minister" do
      let(:selected_minister) { create(:deleted_minister) }

      it "is included" do
        subject = described_class.active_or_having_id(selected_minister.id)
        expect(subject).to eq [selected_minister, minister]
      end
    end
  end

  describe "Get index" do
    let!(:minister_today_active) { create(:minister, updated_at: Time.zone.now, deleted: false) }
    let!(:minister_today_deleted) { create(:minister, updated_at: Time.zone.now, deleted: true) }
    let!(:minister_yesterday_active) { create(:minister, updated_at: 1.day.ago, deleted: false) }
    let!(:minister_yesterday_deleted) { create(:minister, updated_at: 1.day.ago, deleted: true) }
    let!(:minister_three_days_ago_active) { create(:minister, updated_at: 3.days.ago, deleted: false) }

    it "lists all active Ministers and those made inactive withing the last two days" do
      expect(described_class.active_list).to contain_exactly(minister_today_active, minister_today_deleted, minister_yesterday_active, minister_yesterday_deleted, minister_three_days_ago_active)
    end
  end
end
