class PressDesksController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_press_desk, only: [:show, :edit, :update, :destroy]

  def index
    @press_desks = PressDesk.all.order('lower(name)')
  end

  def new
    @press_desk = PressDesk.new
  end

  def create
    @press_desk = PressDesk.new(press_desk_params)

    if @press_desk.save
      redirect_to @press_desk, notice: 'Press desk was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @press_desk.update(press_desk_params)
      redirect_to @press_desk, notice: 'Press desk was successfully updated.'
    else
      render action: 'edit'
    end
  end

private

  def set_press_desk
    @press_desk = PressDesk.find(params[:id])
  end

  def press_desk_params
    params.require(:press_desk).permit(:name, :deleted)
  end
end
