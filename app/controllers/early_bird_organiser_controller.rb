class EarlyBirdOrganiserController < ApplicationController
  before_action :authenticate_user!

  def new
    update_page_title(t('page.title.earlybird_suspension'))

    @early_bird_organiser = EarlyBirdOrganiser.new

    @previous_early_bird = EarlyBirdOrganiser.last

    if @previous_early_bird && (Time.zone.today < @previous_early_bird.date_to)
      date_from = @previous_early_bird.date_from
      date_to = @previous_early_bird.date_to
      flash[:message] = t('page.flash.earlybird_suppression_date_range')
    end
  end

  def create
    @early_bird_organiser = EarlyBirdOrganiser.new(early_bird_organiser_params)

    if @early_bird_organiser.save
      date_from = @early_bird_organiser.date_from
      date_to = @early_bird_organiser.date_to
      flash[:success] = t('page.flash.earlybird_suppression_date_range_set')
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
