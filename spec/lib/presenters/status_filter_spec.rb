require "rails_helper"

describe Presenters::StatusFilter do
  include Rails.application.routes.url_helpers

  let(:params) do
    {
      qstatus: "test_key",
      controller: "dashboard",
      action: "by_status",
    }
  end
  let(:label) { "test label" }
  let(:filter) { described_class.new(1, "test_key", label, params) }

  describe "#link" do
    it "returns the correct path" do
      expect(filter.path).to eq(dashboard_by_status_path(qstatus: "test_key"))
    end
  end

  describe "#active?" do
    context "when key and active_key match" do
      it "returns true" do
        expect(filter).to be_active
      end
    end

    context "when key and active_key do not match" do
      let(:params) do
        {
          qstatus: "other-key",
          controller: "dashboard",
          action: "by_status",
        }
      end

      it "returns false" do
        expect(filter).not_to be_active
      end
    end
  end

  describe "#label" do
    context "when no label has been supplied" do
      let(:label) { nil }

      it "returns the key value" do
        expect(filter.label).to eq("test_key")
      end
    end

    context "when a label is supplied" do
      it "returns the label value" do
        expect(filter.label).to eq("test label")
      end
    end
  end
end
