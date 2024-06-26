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
end
