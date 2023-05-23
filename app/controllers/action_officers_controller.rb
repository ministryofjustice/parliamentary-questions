class ActionOfficersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @show_inactive = (params[:show_inactive] == 'true')
    list = @show_inactive ? ActionOfficer.inactive_list : ActionOfficer.active_list

    @action_officers = list.joins(deputy_director: :division)
                           .order(deleted: :asc)
                           .order(Arel.sql('lower(divisions.name)'))
                           .order(Arel.sql('lower(action_officers.name)'))

    update_page_title(t('page.title.action_officers'))
  end

  def show
    loading_existing_records
    update_page_title(t('page.title.action_officer_details'))
  end

  def new
    loading_new_records
    update_page_title(t('page.title.action_officer_add'))
  end

  def edit
    loading_existing_records
    update_page_title(t('page.title.action_officer_edit'))
  end

  def create
    loading_new_records do
      if @action_officer.update(action_officer_params)
        flash[:success] = t('page.flash.action_officer_created')
        redirect_to action_officers_path
      else
        flash[:error] = t('page.flash.ao_create_failed')
        update_page_title(t('page.title.action_officer_add'))
        render action: 'new'
      end
    end
  end

  def update
    loading_existing_records do
      if @action_officer.update(action_officer_params)
        flash[:success] = t('page.flash.action_officer_updated')
        redirect_to action_officer_path(@action_officer)
      else
        flash[:error] = t('page.flash.action_officer_update_failed')
        update_page_title(t('page.title.ao_edit'))
        render action: 'edit'
      end
    end
  end

  def find
    render json: ActionOfficer.by_name(params[:q]).select(:id, :name)
  end

  private

  def loading_new_records
    loading_defaults
    @action_officer = ActionOfficer.new
    yield if block_given?
  end

  def loading_existing_records
    loading_defaults
    @action_officer = ActionOfficer.find(params[:id])
    yield if block_given?
  end

  def loading_defaults
    @deputy_directors = DeputyDirector.active
    @press_desks      = PressDesk.active
  end

  def action_officer_params
    params
      .require(:action_officer)
      .permit(
        :name,
        :email,
        :group_email,
        :phone,
        :deleted,
        :deputy_director_id,
        :press_desk_id
      )
  end
end
