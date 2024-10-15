require "rails_helper"
require Rails.root.join("spec/support/features/session_helpers").to_s

describe DashboardController, type: :controller do
  context "when sorting the dashboard" do
    describe "GET backlog" do
      it "sorts the Backlog questions by date and state weight and return them all" do
        setup_questions
        allow(PqUserFilter).to receive(:before).and_return(true)
        expect(PqUserFilter).to receive(:before)
        allow(controller).to receive(:authenticate_user!).and_return(true)
        expect(controller).to receive(:authenticate_user!)
        get :backlog
        expect(response.status).to eq(200)
        expect(assigns(:questions).map(&:uin)).to eq expected_order_of_overdue_questions
      end
    end

    describe "GET by_status" do
      it "returns all questions in unassigned status sorted for dashboard order" do
        setup_questions
        allow(PqUserFilter).to receive(:before).and_return(true)
        expect(PqUserFilter).to receive(:before)
        allow(controller).to receive(:authenticate_user!).and_return(true)
        expect(controller).to receive(:authenticate_user!)
        get :unassigned
        expect(response.status).to eq(200)
        expect(assigns(:questions).map(&:uin)).to eq expected_order_of_unassigned_questions
      end
    end

    describe "GET in_progress" do
      it "sorts the in-progress questions by date and state weight and return them all" do
        setup_questions
        allow(PqUserFilter).to receive(:before).and_return(true)
        expect(PqUserFilter).to receive(:before)
        allow(controller).to receive(:authenticate_user!).and_return(true)
        expect(controller).to receive(:authenticate_user!)
        get :in_progress
        expect(response.status).to eq(200)
        expect(assigns(:questions).map(&:uin)).to eq expected_order_in_progress_questions
      end
    end

    describe "GET index" do
      it "sorts the new questions by date and state weight" do
        setup_questions
        allow(PqUserFilter).to receive(:before).and_return(true)
        expect(PqUserFilter).to receive(:before)
        allow(controller).to receive(:authenticate_user!).and_return(true)
        expect(controller).to receive(:authenticate_user!)
        get :index
        expect(response.status).to eq(200)
        expect(assigns(:questions).map(&:uin)).to eq expected_order_of_new_questions
      end
    end
  end
end

def pq_dates
  [
    Date.yesterday,
    Time.zone.today,
    Date.tomorrow,
  ]
end

def setup_questions
  Pq.delete_all
  PqState::ALL.each_with_index do |state, state_index|
    state_weight = PqState.state_weight(state)
    pq_dates.each_with_index do |date, date_index|
      uin = "UIN-#{date.strftime('%m%d')}:#{state}-#{state_index}#{date_index}"
      FactoryBot.create(:pq, uin:, state:, state_weight:, date_for_answer: date)
    end
  end
end

# UINS of expected results are UIN-<mmdd>:<state_weight>-<unique record id>

def expected_order_of_new_questions
  [
    "UIN-#{Time.zone.today.strftime('%m%d')}:no_response-11",
    "UIN-#{Time.zone.today.strftime('%m%d')}:rejected-21",
    "UIN-#{Time.zone.today.strftime('%m%d')}:unassigned-01",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:no_response-12",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:rejected-22",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:unassigned-02",
    "UIN-#{Date.yesterday.strftime('%m%d')}:no_response-10",
    "UIN-#{Date.yesterday.strftime('%m%d')}:rejected-20",
    "UIN-#{Date.yesterday.strftime('%m%d')}:unassigned-00",
  ]
end

def expected_order_of_overdue_questions
  [
    "UIN-#{Date.yesterday.strftime('%m%d')}:minister_cleared-90",
    "UIN-#{Date.yesterday.strftime('%m%d')}:pod_cleared-60",
    "UIN-#{Date.yesterday.strftime('%m%d')}:with_minister-70",
    "UIN-#{Date.yesterday.strftime('%m%d')}:ministerial_query-80",
    "UIN-#{Date.yesterday.strftime('%m%d')}:with_pod-40",
    "UIN-#{Date.yesterday.strftime('%m%d')}:pod_query-50",
    "UIN-#{Date.yesterday.strftime('%m%d')}:draft_pending-30",
    "UIN-#{Date.yesterday.strftime('%m%d')}:no_response-10",
    "UIN-#{Date.yesterday.strftime('%m%d')}:rejected-20",
    "UIN-#{Date.yesterday.strftime('%m%d')}:unassigned-00",
  ]
end

def expected_order_in_progress_questions
  [
    "UIN-#{Time.zone.today.strftime('%m%d')}:minister_cleared-91",
    "UIN-#{Time.zone.today.strftime('%m%d')}:pod_cleared-61",
    "UIN-#{Time.zone.today.strftime('%m%d')}:with_minister-71",
    "UIN-#{Time.zone.today.strftime('%m%d')}:ministerial_query-81",
    "UIN-#{Time.zone.today.strftime('%m%d')}:with_pod-41",
    "UIN-#{Time.zone.today.strftime('%m%d')}:pod_query-51",
    "UIN-#{Time.zone.today.strftime('%m%d')}:draft_pending-31",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:minister_cleared-92",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:pod_cleared-62",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:with_minister-72",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:ministerial_query-82",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:with_pod-42",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:pod_query-52",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:draft_pending-32",
  ]
end

def expected_order_of_unassigned_questions
  [
    "UIN-#{Time.zone.today.strftime('%m%d')}:unassigned-01",
    "UIN-#{Date.tomorrow.strftime('%m%d')}:unassigned-02",
    "UIN-#{Date.yesterday.strftime('%m%d')}:unassigned-00",
  ]
end
