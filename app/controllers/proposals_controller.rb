class ProposalsController < ApplicationController

  def new
  	byebug
  	@action_officers = ActionOfficer.all
  end	

end