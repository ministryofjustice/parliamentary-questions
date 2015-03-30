class PressOfficersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_press_officer, only: [:show, :edit, :update, :destroy]
  before_action :prepare_press_offices

  def index
    @press_officers = PressOfficer.order('lower(name)')
    update_page_title('Press Officers Index')
  end

  def new
    @press_officer = PressOfficer.new
    update_page_title('Add Press Officer')
  end

  def show
    update_page_title('Press Officer Details')
  end

  def edit
    update_page_title('Edit Press Officer')
  end


  def create
    @press_officer = PressOfficer.new(press_officer_params)

    if @press_officer.save
      flash[:success] = 'Press officer was successfully created.'
      redirect_to @press_officer
    else
      render action: 'new'
    end
  end

  def update
    if @press_officer.update(press_officer_params)
      flash[:success] = 'Press officer was successfully updated.'
      redirect_to @press_officer
    else
      render action: 'edit'
    end
  end

  private

  def set_press_officer
    @press_officer = PressOfficer.find(params[:id])
  end

  def press_officer_params
    params.require(:press_officer).permit(:name, :email, :press_desk_id, :deleted)
  end

  def prepare_press_offices
    @press_offices = PressDesk.active
  end
end
