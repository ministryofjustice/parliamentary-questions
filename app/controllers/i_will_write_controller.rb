class IWillWriteController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def create
    pq        = Pq.find_by!(uin: params[:id])
    target_pq = pq.is_follow_up? ? pq : pq.find_or_create_follow_up
    redirect_to pq_path(target_pq.uin)
  end
end
