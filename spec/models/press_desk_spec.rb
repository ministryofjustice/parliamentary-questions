# == Schema Information
#
# Table name: press_desks
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted    :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "spec_helper"

describe PressDesk do
  let(:pdesk) { build(:press_desk) }

  it "passes factory build" do
    expect(pdesk).to be_valid
  end

  it "has a name" do
    pdesk.name = nil
    expect(pdesk).to be_invalid
  end

  it "has a unique name" do
    create(:press_desk, name: "Finance desk")
    duplicate = build(:press_desk, name: "Finance desk")
    expect(duplicate).to be_invalid
  end

  it "exposes a press_officer_emails method" do
    pdesk.press_officers << build(:press_officer, name: "PO one", email: "po.one@po.com")
    pdesk.press_officers << build(:press_officer, name: "PO two", email: "po.two@po.com")

    expect(pdesk.press_officer_emails).to eql(["po.one@po.com", "po.two@po.com"])
  end

  it "exposes a press_officer_emails method to not include deleted ones" do
    pdesk.press_officers << build(:press_officer, name: "PO one", email: "po.one@po.com", deleted: true)
    pdesk.press_officers << build(:press_officer, name: "PO two", email: "po.two@po.com", deleted: false)

    expect(pdesk.press_officer_emails).to eql(["po.two@po.com"])
  end

  describe "associations" do
    it "has a collection of press officers" do
      expect(pdesk).to respond_to(:press_officers)
    end

    it "has a collection of action officers" do
      expect(pdesk).to respond_to(:action_officers)
    end
  end
end
