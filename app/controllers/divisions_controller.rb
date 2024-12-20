class DivisionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_division, only: %i[show edit update destroy]
  before_action :prepare_directorates

  def index
    @divisions = Division.active_list
                         .joins(:directorate)
                         .order(deleted: :asc)
                         .order(Arel.sql("lower(directorates.name)"))
                         .order(Arel.sql("lower(divisions.name)"))
    update_page_title("Divisions")
  end

  def new
    @division = Division.new
    update_page_title("Add division")
  end

  def show
    update_page_title("Division details")
  end

  def edit
    update_page_title("Edit division")
  end

  def create
    @division = Division.new(division_params)

    if @division.save
      flash[:success] = "Division was successfully created."
      redirect_to @division
    else
      render action: "new"
    end
  end

  def update
    if @division.update(division_params)
      flash[:succees] = "Division successfully updated"
      redirect_to @division
    else
      render action: "edit"
    end
  end

  def destroy
    # This method is not implemented as we 'soft' delete data.
  end

private

  def set_division
    @division = Division.find(params[:id])
  end

  def division_params
    params.require(:division).permit(:name, :deleted, :directorate_id)
  end

  def prepare_directorates
    @directorates = Directorate.active.order(Arel.sql("lower(name)"))
  end
end
