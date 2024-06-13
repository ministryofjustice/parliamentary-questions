require "feature_helper"

describe "/healthcheck" do
  let(:database_healthcheck) { instance_double(HealthCheck::Database, available?: true, accessible?: true, error_messages: errors) }
  let(:api_healthcheck) { instance_double(HealthCheck::PQAApi, available?: true, accessible?: true, error_messages: nil) }

  before do
    allow(HealthCheck::Database).to receive(:new).and_return(database_healthcheck)
    allow(HealthCheck::PQAApi).to receive(:new).and_return(api_healthcheck)
  end

  context "without errors" do
    let(:errors) { nil }

    it "when there are no errors it should return a 200 code" do
      visit "/healthcheck"

      expect(page.status_code).to eq 200
      expect(page).to have_content "All Components OK"
    end
  end

  context "with errors" do
    let(:errors) { "Database Error" }

    it "when there are component errors" do
      visit "/healthcheck"

      expect(page.status_code).to eq 500
      expect(page.body).to match(/Database Error/)
    end
  end
end
