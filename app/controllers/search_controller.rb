class SearchController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    uin = params[:search]
    pq  = Pq.where("lower(uin) = :p", p: uin.downcase)

    if pq.empty?
      flash[:error] = "Question with UIN '#{uin}' not found"
      redirect_to controller: 'dashboard', action: 'index'
    else
      redirect_to pq_path(pq.first.uin)
    end
  end
end
