class EarlyBirdDashboardController < ApplicationController
  before_action AoTokenFilter, only: [:index]
  before_action :save_early_bird_credentials, only: [:index]
  before_action :authenticate_user!, only: [:preview]

  PER_PAGE = 200
  QUESTIONS_URL = "https://questions-statements.parliament.uk".freeze

  def index
    update_page_title("Early bird preview")
    @now = Time.zone.now.strftime("%d/%m/%Y")
    @questions = Pq.new_questions.or(Pq.imported_since_last_weekday).order(:uin)
    @parliament_url = QUESTIONS_URL
  end

  def preview
    index
    render "index"
  end

private

  def save_early_bird_credentials
    session[:early_bird_token] = params[:token]
    session[:early_bird_entity] = params[:entity]
  end
end
