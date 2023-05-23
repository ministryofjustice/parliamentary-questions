class PressDesksController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_press_desk, only: [:show, :edit, :update, :destroy]

  def index
    @press_desks = PressDesk.active_list.all.order('lower(name)')
    update_page_title(t('page.title.press_desks'))
  end

  def show
    update_page_title(t('page.title.press_desk_details'))
  end

  def new
    @press_desk = PressDesk.new
    update_page_title(t('page.title.press_desk_add'))
  end

  def edit
    update_page_title(t('page.title.press_desk_edit'))
  end

  def create
    @press_desk = PressDesk.new(press_desk_params)

    if @press_desk.save
      flash[:success] = t('page.title.press_desk_created')
      redirect_to @press_desk
    else
      render action: 'new'
    end
  end

  def update
    if @press_desk.update(press_desk_params)
      flash[:success] = t('page.title.press_desk_updated')
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
