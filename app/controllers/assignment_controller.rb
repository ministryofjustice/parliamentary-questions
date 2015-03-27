class AssignmentController < ApplicationController
  before_action AOTokenFilter

  

  def show
    update_page_title 'PQ Assignment'
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
      @response       = AllocationResponse.new(response_params)
      response_action = @response.response_action
      update_page_title 'PQ Assignment'

      unless @response.valid?
        flash[:error] = "Form was not completed"
        render 'show'
      else
        service = AssignmentService.new
        case response_action
        when 'accept'
          update_page_title "PQ Assigned"
          service.accept(@assignment)
        when 'reject'
          update_page_title "PQ Rejected"
          service.reject(@assignment, @response)
        else
          msg = "AllocationResponse.response_action must be set to either 'accept' or 'reject'. Got #{response_action}"
          raise ArgumentError, msg
          #TODO: log unexpected input
        end
        render 'confirmation'
      end
    end
  end

  private

  def loading_question_and_assignment
    _, assignment_id = params[:entity].split(':')
    @question = Pq.find_by!(uin: params[:uin])

    if assignment_id
      @assignment = @question.action_officers_pqs.find(assignment_id)
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
