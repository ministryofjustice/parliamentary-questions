require "rails_helper"

RSpec.describe PingController, type: :controller do
  describe "#index" do
    it "returns a minimal JSON status with no build or infrastructure detail" do
      get :index

      expect(response.body).to eq({ status: "ok" }.to_json)
    end
  end

  describe "#deploy_info" do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("DEPLOY_DASHBOARD_SHARED_SECRET", nil).and_return("test-secret")
    end

    context "with a valid shared secret" do
      before { request.headers["X-Deploy-Dashboard-Secret"] = "test-secret" }

      it "returns JSON with app information" do
        get :deploy_info

        deploy_info_response = JSON.parse response.body
        expect(deploy_info_response["build_date"]).to eq Deployment.build_date
        expect(deploy_info_response["commit_id"]).to eq Deployment.commit_id
        expect(deploy_info_response["build_tag"]).to eq Deployment.build_tag
      end
    end

    context "with an invalid shared secret" do
      before { request.headers["X-Deploy-Dashboard-Secret"] = "wrong-secret" }

      it "returns unauthorized" do
        get :deploy_info

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "without a shared secret header" do
      it "returns unauthorized" do
        get :deploy_info

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
