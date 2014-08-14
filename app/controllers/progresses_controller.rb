class ProgressesController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_progress, only: [:show, :edit, :update, :destroy]

  # GET /progresses
  # GET /progresses.json
  def index
    @progresses = Progress.all
  end

  # GET /progresses/1
  # GET /progresses/1.json
  def show
  end

  # GET /progresses/new
  def new
    @progress = Progress.new
  end

  # GET /progresses/1/edit
  def edit
  end

  # POST /progresses
  def create
    @progress = Progress.new(progress_params)

      if @progress.save
        redirect_to @progress, notice: 'Progress was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /progresses/1
  def update
      if @progress.update(progress_params)
        redirect_to @progress, notice: 'Progress was successfully updated.'
      else
        render action: 'edit'
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_progress
      @progress = Progress.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def progress_params
      params.require(:progress).permit( :name, :progress_order)
    end
end
