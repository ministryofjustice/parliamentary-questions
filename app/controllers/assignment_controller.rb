class AssignmentController < ApplicationController
  before_action AOTokenFilter

  def show
    loading_question_and_assignment do
      if @question.action_officers_pqs.accepted || @assignment.rejected?
        render 'confirmation'
      else
        @response = AllocationResponse.new
      end
    end
  end

  def create
    loading_question_and_assignment do
      @response = AllocationResponse.new(response_params)
      unless @response.valid?
        render 'show'
      else
        service = AssignmentService.new
        case @response.response_action
        when 'accept'
          service.accept(@assignment)
        when 'reject'
          service.reject(@assignment, @response)
        else
          #TODO: log unexpected input
        end
        render 'confirmation'
      end
    end
  end

  private

  def loading_question_and_assignment
    _, assignment_id = params[:entity].split(':')
    @question = Pq.find_by(uin: params[:uin])

    if assignment_id
      @assignment = ActionOfficersPq.find(assignment_id)
      @ao         = @assignment.action_officer
      yield
    else
      render :file => 'public/404.html', :status => :not_found
    end
  end

  def response_params
    params.require(:allocation_response).permit(:response_action, :reason_option, :reason)
  end
end
