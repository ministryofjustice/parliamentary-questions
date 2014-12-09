class DashboardController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  @@per_page = 5

  def index
    @questions = paginate_collection(Pq.in_state(states))
  end

  def search
  end

  helper_method def tab
    @tab ||= params[:tab].try(:to_sym) || :new
  end

  helper_method def states
    @states ||= if tab == :new
      QuestionStateMachine.new_questions
    else
      QuestionStateMachine.in_progress
    end
  end

private

  def paginate_collection(pqs)
    pqs.paginate(page: params[:page], per_page: @@per_page).
      order("date_for_answer_has_passed, days_from_date_for_answer, state DESC, updated_at").
      load
  end
end
