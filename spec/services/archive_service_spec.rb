require "rails_helper"

describe ArchiveService do
  subject(:service) { described_class.new(archive) }

  before do
    create_list(:pq, 10)
  end

  describe "#archive_current" do
    let(:archive) { create(:archive, prefix: "a") }

    it "sets all unarchived questions as archived" do
      expect {
        service.archive_current
      }.to change {
        Pq.unarchived.count
      }.from(10).to(0)
    end

    it "adds the expected prefix to all unarchived questions" do
      service.archive_current

      expect(Pq.all.all? { |p| p.uin.first == "a" }).to be true
    end

    context "when archive is invalid" do
      let(:archive) { build(:archive, prefix: "a") }

      before do
        create(:archive, prefix: "a")
      end

      it "raises an error" do
        expect { service.archive_current }.to raise_error(InvalidArchiveError)
      end

      it "does not update any questions" do
        service.archive_current rescue nil # rubocop:disable Style/RescueModifier - ignore exception as that is expected
        expect(Pq.unarchived.count).to eq 10
        expect(Pq.all.any? { |p| p.uin.first == "a" }).to be false
      end
    end
  end
end
