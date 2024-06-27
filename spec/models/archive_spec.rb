# == Schema Information
#
# Table name: archives
#
#  id         :bigint           not null, primary key
#  prefix     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "spec_helper"

describe Archive do
  let(:archive) { build(:archive) }

  describe "validation" do
    it "passes onfactory build" do
      expect(archive).to be_valid
    end

    it "has a prefix" do
      archive.prefix = nil
      expect(archive).to be_invalid
    end

    it "has a unique prefix" do
      create(:archive, prefix: "s")
      duplicate = build(:archive, prefix: "s")
      expect(duplicate).to be_invalid
    end

    it "doesn't have a numeric prefix" do
      archive.prefix = "ab1"
      expect(archive).to be_invalid
    end

    it "downcases the prefix" do
      archive.prefix = "T"
      archive.save!
      expect(archive.prefix).to eq "t"
    end
  end

  describe ".all_prefixes" do
    it "returns string listing all prefixes" do
      p1 = create(:archive).prefix
      p2 = create(:archive).prefix
      p3 = create(:archive).prefix
      p4 = create(:archive).prefix

      expect(described_class.all_prefixes).to eq "#{p1}, #{p2}, #{p3}, #{p4}"
    end
  end
end
