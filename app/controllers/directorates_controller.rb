class DirectoratesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_directorate, only: %i[show edit update destroy]

  def index
    @directorates = Directorate.active_list
                               .order(deleted: :asc)
                               .order(Arel.sql("lower(name)"))
    update_page_title("Directorates")
  end

  def new
    @directorate = Directorate.new
    update_page_title("Add a directorate")
  end

  def show
    update_page_title("Directorate details")
  end

  def edit
    update_page_title("Edit directorate")
  end

  def create
    @directorate = Directorate.new(directorate_params)
    if @directorate.save
      flash[:success] = "Directorate was successfully created."
      redirect_to @directorate
    else
      render action: "new"
    end
  end

  def update
    if @directorate.update(directorate_params)
      flash[:success] = "Directorate was successfully updated."
      redirect_to @directorate
    else
      render action: "edit"
    end
  end

  def destroy
    # This method is not implemented as we 'soft' delete data.
  end

private

  def set_directorate
    @directorate = Directorate.find(params[:id])
  end

  def directorate_params
    params.require(:directorate).permit(:name, :deleted)
  end
end
