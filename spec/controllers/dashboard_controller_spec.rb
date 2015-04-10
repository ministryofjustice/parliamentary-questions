require 'spec_helper'
require "#{Rails.root}/spec/support/features/session_helpers"

describe DashboardController, type: :controller do


  context 'dashboard sorting' do


    describe 'GET index' do
      it 'should sort the new questions by date and state weight' do
        Timecop.freeze(DateTime.new(2015, 5, 1, 14, 4, 45)) do
          setup_questions
          expect(PQUserFilter).to receive(:before).and_return(true)
          expect(controller).to receive(:authenticate_user!).and_return(true)
          get :index
          expect(response.status).to eq(200)
          expect(assigns(:questions).map(&:uin)).to eq expected_order_of_new_questions
        end
      end
    end


    describe 'GET in_progress' do
      it 'should sort the in-progress questions by date and state weight and return first fifteen' do
        Timecop.freeze(DateTime.new(2015, 5, 1, 14, 4, 45)) do
          setup_questions
          expect(PQUserFilter).to receive(:before).and_return(true)
          expect(controller).to receive(:authenticate_user!).and_return(true)
          get :in_progress
          expect(response.status).to eq(200)
          expect(assigns(:questions).map(&:uin)).to eq expected_order_in_progress_questions_first_page
        end
      end

      it 'should sort the in-progress questions by date and state weight and return second fifteen' do
        Timecop.freeze(DateTime.new(2015, 5, 1, 14, 4, 45)) do
          setup_questions
          expect(PQUserFilter).to receive(:before).and_return(true)
          expect(controller).to receive(:authenticate_user!).and_return(true)
          get :in_progress, page: 2
          expect(response.status).to eq(200)
          expect(assigns(:questions).map(&:uin)).to eq expected_order_in_progress_questions_second_page
        end
      end


      it 'should sort the in-progress questions by date and state weight and return last five' do
        Timecop.freeze(DateTime.new(2015, 5, 1, 14, 4, 45)) do
          setup_questions
          expect(PQUserFilter).to receive(:before).and_return(true)
          expect(controller).to receive(:authenticate_user!).and_return(true)
          get :in_progress, page: 3
          expect(response.status).to eq(200)
          expect(assigns(:questions).map(&:uin)).to eq expected_order_in_progress_questions_third_page
        end
      end
    end
  end
end



def setup_questions
  Pq.delete_all
  PQState::ALL.each_with_index do |state, index1|
    state_weight = PQState.state_weight(state)
    pq_dates.each_with_index do |date, index2|
      uin = "UIN-#{date.strftime('%m%d')}:#{state_weight}-#{index1}#{index2}"
      FactoryGirl.create(:pq, uin: uin, state: state, state_weight: state_weight, date_for_answer: date)
    end
  end
end


def pq_dates
  [
    Date.new(2015, 4, 29),
    Date.new(2015, 4, 30),
    Date.new(2015, 5, 1),
    Date.new(2015, 5, 2),
    Date.new(2015, 5, 3),
  ]
end


# UINS of expected results are UIN-<mmdd>:<state_weight>-<unique record id>

def expected_order_of_new_questions
  [
    "UIN-0501:1-12", 
    "UIN-0501:1-22", 
    "UIN-0501:0-02", 
    "UIN-0502:1-23", 
    "UIN-0502:1-13", 
    "UIN-0502:0-03", 
    "UIN-0503:1-24", 
    "UIN-0503:1-14", 
    "UIN-0503:0-04", 
    "UIN-0430:1-21", 
    "UIN-0430:1-11", 
    "UIN-0430:0-01", 
    "UIN-0429:1-10", 
    "UIN-0429:1-20", 
    "UIN-0429:0-00"
  ]
end

def expected_order_in_progress_questions_first_page
  [
    "UIN-0501:6-92", 
    "UIN-0501:5-62", 
    "UIN-0501:4-82", 
    "UIN-0501:4-72", 
    "UIN-0501:3-52", 
    "UIN-0501:3-42", 
    "UIN-0501:2-32", 
    "UIN-0502:6-93", 
    "UIN-0502:5-63", 
    "UIN-0502:4-73", 
    "UIN-0502:4-83", 
    "UIN-0502:3-53", 
    "UIN-0502:3-43", 
    "UIN-0502:2-33", 
    "UIN-0503:6-94"
  ]
end

def expected_order_in_progress_questions_second_page
  [
    "UIN-0503:5-64", 
    "UIN-0503:4-74", 
    "UIN-0503:4-84", 
    "UIN-0503:3-54", 
    "UIN-0503:3-44", 
    "UIN-0503:2-34", 
    "UIN-0430:6-91", 
    "UIN-0430:5-61", 
    "UIN-0430:4-81", 
    "UIN-0430:4-71", 
    "UIN-0430:3-51", 
    "UIN-0430:3-41", 
    "UIN-0430:2-31", 
    "UIN-0429:6-90", 
    "UIN-0429:5-60"
  ]
end

def expected_order_in_progress_questions_third_page
  [
    "UIN-0429:4-80", 
    "UIN-0429:4-70", 
    "UIN-0429:3-40", 
    "UIN-0429:3-50", 
    "UIN-0429:2-30"
  ]
end
