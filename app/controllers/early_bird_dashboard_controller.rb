class EarlyBirdDashboardController < ApplicationController
  before_action AoTokenFilter, only: [:index]
  before_action :save_early_bird_credentials, only: [:index]
  before_action :authenticate_user!, PqUserFilter, only: [:preview]

  NEW      = "New".freeze
  PER_PAGE = 200

  def index
    update_page_title("Early bird preview")
    @now            = Time.zone.now.strftime("%d/%m/%Y")
    @questions      = Pq.new_questions.order(:uin)
    @parliament_url = PQA::RecentQuestionsUrl.url(Time.zone.today)
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

  def load_pq_with_counts
    @questions = paginate_collection(yield) if block_given?
  end

  def paginate_collection(pqs)
    page = params.fetch(:page, 1)
    pqs.paginate(page:, per_page: PER_PAGE)
  end
end
