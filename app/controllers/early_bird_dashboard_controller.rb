class EarlyBirdDashboardController < ApplicationController
  before_action AOTokenFilter, only: [:index]
  before_action :authenticate_user!, PQUserFilter, only: [:preview]

  def index
  	update_page_title('Early bird preview')
    @questions = Pq.with_pod
    #@questions = Pq.new_questions
  end

  def preview
    index
    render 'index'
  end
end
