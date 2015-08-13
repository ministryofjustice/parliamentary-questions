class EarlyBirdDashboardController < ApplicationController
  before_action AOTokenFilter, only: [:index]
  before_action :authenticate_user!, PQUserFilter, only: [:preview]

  def index
  	update_page_title('Early bird preview')
    @now = Time.now.strftime("%d/%m/%Y")
   # @questions = Pq.with_pod
    @questions = Pq.new_questions.order(:uin)
    @parliament_url = PQA::RecentQuestionsURL.url(Date.today())
  end

  def preview
    index
    render 'index'
  end

  NEW      = 'New'
  PER_PAGE = 200

  #def index
  #   @preview_state = NEW
   # @now = Time.now.strftime("%d/%m/%Y")
   # update_page_title "Early bird preview"
    #load_pq_with_counts { Pq.new_questions.sorted_for_dashboard }
    #load_pq_with_counts { Pq.with_pod.sorted_for_dashboard }
  #end

  #def preview
  #  index
  #  render 'index'
 # end

  private

  def load_pq_with_counts
    @questions = paginate_collection(yield) if block_given?
  end

  def paginate_collection(pqs)
    page = params.fetch(:page, 1)
    pqs.paginate(page: page, per_page: PER_PAGE)
  end

end
