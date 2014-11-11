class SearchController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    if params[:search] == nil
      return redirect_to controller: 'dashboard', action: 'index'
    end

    uin = params[:search]

    pq = Pq.where("lower(uin) = :p", p: uin.downcase)

    if pq.nil? || pq.size==0
      flash[:notice] = "The Question with UIN '#{uin}' not found"
      return redirect_to controller: 'dashboard', action: 'index'
    end

    return redirect_to pq_path(pq.first.uin)
  end
end
