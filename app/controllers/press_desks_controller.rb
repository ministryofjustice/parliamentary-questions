class PressDesksController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_press_desk, only: [:show, :edit, :update, :destroy]

  # GET /press_desks
  # GET /press_desks.json
  def index
    @press_desks = PressDesk.all.order('lower(name)')
  end

  # GET /press_desks/1
  # GET /press_desks/1.json
  def show
  end

  # GET /press_desks/new
  def new
    @press_desk = PressDesk.new
  end

  # GET /press_desks/1/edit
  def edit
  end

  # POST /press_desks
  def create
    @press_desk = PressDesk.new(press_desk_params)

      if @press_desk.save
        redirect_to @press_desk, notice: 'Press desk was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /press_desks/1
  def update
      if @press_desk.update(press_desk_params)
        redirect_to @press_desk, notice: 'Press desk was successfully updated.'
      else
        render action: 'edit'
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_press_desk
      @press_desk = PressDesk.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def press_desk_params
      params.require(:press_desk).permit(:name, :deleted)
    end
end
