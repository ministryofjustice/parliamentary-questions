class ProgressesController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_progress, only: [:show, :edit, :update, :destroy]

  def index
    @progresses = Progress.all
  end

  def new
    @progress = Progress.new
  end

  def create
    @progress = Progress.new(progress_params)

    if @progress.save
      redirect_to @progress, notice: 'Progress was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @progress.update(progress_params)
      redirect_to @progress, notice: 'Progress was successfully updated.'
    else
      render action: 'edit'
    end
  end

private

  def set_progress
    @progress = Progress.find(params[:id])
  end

  def progress_params
    params.require(:progress).permit( :name, :progress_order)
  end
end
