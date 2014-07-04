class SearchController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    if params[:search] == nil
      return redirect_to controller: 'dashboard', action: 'index'
    end

    uin = params[:search]
    pq = PQ.find_by(uin: uin)

    if pq.nil?
      flash[:notice] = "The Question with UIN '#{uin}' not found"
      return redirect_to controller: 'dashboard', action: 'index'
    end

    return redirect_to controller: 'pqs', action: 'show', id: uin

  end


end