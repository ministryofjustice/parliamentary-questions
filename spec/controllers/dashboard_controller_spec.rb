require 'spec_helper'
require "#{Rails.root}/spec/support/features/session_helpers"

describe DashboardController, type: :controller do

  context 'dashboard sorting' do

    describe 'GET index' do
      it 'should sort the new questions by date and state weight' do
          setup_questions
          expect(PQUserFilter).to receive(:before).and_return(true)
          expect(controller).to receive(:authenticate_user!).and_return(true)
          get :index
          expect(response.status).to eq(200)
          expect(assigns(:questions).map(&:uin)).to eq expected_order_of_new_questions
      end
    end


    describe 'GET in_progress' do
      it 'should sort the in-progress questions by date and state weight and return them all' do
          setup_questions
          expect(PQUserFilter).to receive(:before).and_return(true)
          expect(controller).to receive(:authenticate_user!).and_return(true)
          get :in_progress
          expect(response.status).to eq(200)
          expect(assigns(:questions).map(&:uin)).to eq expected_order_in_progress_questions
      end
    end

    describe 'GET backlog' do
      it 'should sort the Backlog questions by date and state weight and return them all' do
        setup_questions
        expect(PQUserFilter).to receive(:before).and_return(true)
        expect(controller).to receive(:authenticate_user!).and_return(true)
        get :backlog
        expect(response.status).to eq(200)
        expect(assigns(:questions).map(&:uin)).to eq expected_order_of_overdue_questions
      end
    end

    describe 'GET by_status' do
      it 'should return all questions in unassigned status sorted for dashboard order' do
          setup_questions
          expect(PQUserFilter).to receive(:before).and_return(true)
          expect(controller).to receive(:authenticate_user!).and_return(true)
          get :by_status, qstatus: 'unassigned'
          expect(response.status).to eq(200)
          expect(assigns(:questions).map(&:uin)).to eq expected_order_of_unassigned_questions
      end
    end
  end
end

def setup_questions
  Pq.delete_all
  PQState::ALL.each_with_index do |state, state_index|
    state_weight = PQState.state_weight(state)
    pq_dates.each_with_index do |date, date_index|
      uin = "UIN-#{date.strftime('%m%d')}:#{state}-#{state_index}#{date_index}"
      FactoryGirl.create(:pq, uin: uin, state: state, state_weight: state_weight, date_for_answer: date)
    end
  end
end


def setup_i_will_write_questions
  setup_questions
  questions = Pq.where('state NOT IN (?)', PQState::CLOSED)
  questions.each { |q| q.update_attributes( { i_will_write: true} ) }
end


def pq_dates
  [
    Date.yesterday,
    Date.today,
    Date.tomorrow,
  ]
end

def expected_order_of_unassigned_questions
  [
    "UIN-"+ Date.today.strftime('%m%d') + ":unassigned-01",
    "UIN-"+ Date.tomorrow.strftime('%m%d') + ":unassigned-02",
    "UIN-"+ Date.yesterday.strftime('%m%d') + ":unassigned-00"
  ]
end



# UINS of expected results are UIN-<mmdd>:<state_weight>-<unique record id>

def expected_order_of_new_questions
  [
    "UIN-"+ Date.today.strftime('%m%d') + ":no_response-11",
    "UIN-"+ Date.today.strftime('%m%d') + ":rejected-21",
    "UIN-"+ Date.today.strftime('%m%d') + ":unassigned-01",
    "UIN-"+ Date.tomorrow.strftime('%m%d') + ":no_response-12",
    "UIN-"+ Date.tomorrow.strftime('%m%d') + ":rejected-22",
    "UIN-"+ Date.tomorrow.strftime('%m%d') + ":unassigned-02",
    "UIN-"+ Date.yesterday.strftime('%m%d') + ":no_response-10",
    "UIN-"+ Date.yesterday.strftime('%m%d') + ":rejected-20",
    "UIN-"+ Date.yesterday.strftime('%m%d') + ":unassigned-00"
  ]
end

def expected_order_in_progress_questions
  [
    "UIN-"+ Date.today.strftime('%m%d') + ":minister_cleared-91",
    "UIN-"+ Date.today.strftime('%m%d') +":pod_cleared-61",
    "UIN-"+ Date.today.strftime('%m%d') +":with_minister-71",
    "UIN-"+ Date.today.strftime('%m%d') +":ministerial_query-81",
    "UIN-"+ Date.today.strftime('%m%d') +":with_pod-41",
    "UIN-"+ Date.today.strftime('%m%d') +":pod_query-51",
    "UIN-"+ Date.today.strftime('%m%d') +":draft_pending-31",
    "UIN-"+ Date.tomorrow.strftime('%m%d') +":minister_cleared-92",
    "UIN-"+ Date.tomorrow.strftime('%m%d') +":pod_cleared-62",
    "UIN-"+ Date.tomorrow.strftime('%m%d') +":with_minister-72",
    "UIN-"+ Date.tomorrow.strftime('%m%d') +":ministerial_query-82",
    "UIN-"+ Date.tomorrow.strftime('%m%d') +":with_pod-42",
    "UIN-"+ Date.tomorrow.strftime('%m%d') +":pod_query-52",
    "UIN-"+ Date.tomorrow.strftime('%m%d') +":draft_pending-32"
  ]
end
def expected_order_of_overdue_questions
  ["UIN-"+ Date.yesterday.strftime('%m%d') + ":minister_cleared-90", "UIN-"+ Date.yesterday.strftime('%m%d') + ":pod_cleared-60", "UIN-"+ Date.yesterday.strftime('%m%d') + ":with_minister-70", "UIN-"+ Date.yesterday.strftime('%m%d') + ":ministerial_query-80", "UIN-"+ Date.yesterday.strftime('%m%d') + ":with_pod-40", "UIN-"+ Date.yesterday.strftime('%m%d') + ":pod_query-50", "UIN-"+ Date.yesterday.strftime('%m%d') + ":draft_pending-30", "UIN-"+ Date.yesterday.strftime('%m%d') + ":no_response-10", "UIN-"+ Date.yesterday.strftime('%m%d') + ":rejected-20", "UIN-"+ Date.yesterday.strftime('%m%d') + ":unassigned-00"]

end
