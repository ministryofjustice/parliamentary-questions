class PreviewController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  NEW      = 'New'
  PER_PAGE = 200

  def index
    @preview_state = NEW
    @now = Time.now.strftime("%d/%m/%Y")
    update_page_title "Preview"
    load_pq_with_counts { Pq.new_questions.sorted_for_dashboard }
  end

  private

  def load_pq_with_counts
    @questions = paginate_collection(yield) if block_given?
  end

  def paginate_collection(pqs)
    page = params.fetch(:page, 1)
    pqs.paginate(page: page, per_page: PER_PAGE)
  end
end
