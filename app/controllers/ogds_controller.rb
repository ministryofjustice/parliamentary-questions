class OgdsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_ogd, only: %i[show edit update destroy]

  def index
    @ogds = Ogd.active_list
               .order("lower(name)")
    update_page_title("Other Government Departments")
  end

  def new
    @ogd = Ogd.new
    update_page_title("Add Government Department")
  end

  def show
    update_page_title("Government Department details")
  end

  def edit
    update_page_title("Edit Government Department")
  end

  def create
    @ogd = Ogd.new(ogd_params)

    if @ogd.save
      flash[:success] = "OGD was successfully created."
      redirect_to @ogd
    else
      render action: "new"
    end
  end

  def update
    if @ogd.update(ogd_params)
      flash[:success] = "OGD was successfully updated."
      redirect_to @ogd
    else
      render action: "edit"
    end
  end

  def destroy
    # This method is not implemented as we 'soft' delete data.
  end

  def find
    @results = Ogd.by_name(params[:q]).select(:id, :name, :deleted)
    render json: @results
  end

private

  def set_ogd
    @ogd = Ogd.find(params[:id])
  end

  def ogd_params
    params.require(:ogd).permit(:name, :acronym, :deleted)
  end
end
