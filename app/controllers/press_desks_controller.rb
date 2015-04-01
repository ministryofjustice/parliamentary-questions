class PressDesksController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_press_desk, only: [:show, :edit, :update, :destroy]

  def index
    @press_desks = PressDesk.all.order('lower(name)')
    update_page_title('Press Desks')
  end

  def new
    @press_desk = PressDesk.new
    update_page_title('Add press desk')
  end

  def show
    update_page_title('Press desk details')
  end

  def edit
    update_page_title('Edit press desk')
  end


  def create
    @press_desk = PressDesk.new(press_desk_params)

    if @press_desk.save
      flash[:success] = 'Press desk was successfully created.'
      redirect_to @press_desk
    else
      render action: 'new'
    end
  end

  def update
    if @press_desk.update(press_desk_params)
      flash[:success] = 'Press desk was successfully updated.'
      redirect_to @press_desk
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
