class EarlyBirdOrganiserController < ApplicationController
  before_action :authenticate_user!

  def new
    @early_bird_organiser = EarlyBirdOrganiser.new
  end

  def create
    @early_bird_organiser = EarlyBirdOrganiser.new(early_bird_organiser_params)

    if @early_bird_organiser.save
      date_from = @early_bird_organiser.date_from
      date_to = @early_bird_organiser.date_to
      flash[:success] = "You have succesfully schedued the early bird to be turned off from #{date_from} until #{date_to}"
      redirect_to admin_path
    else
      render action: 'new'
    end
  end

  private
  def early_bird_organiser_params
     params.require(:early_bird_organiser).permit(:date_from, :date_to) 
  end
end
