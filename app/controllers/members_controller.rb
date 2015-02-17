class MembersController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def by_name
    @members = ParliService.new.member_by_name(params[:name])
    render :partial => 'by_name'
  end
end
