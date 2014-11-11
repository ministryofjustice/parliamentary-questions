class MembersController  < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :load_service

  def by_name
    @members = @members_client.members(params[:name])
    render :partial => 'by_name'
  end

protected

  def load_service(members_client = MembersHttpClient.new)
    @members_client ||= members_client
  end
end
