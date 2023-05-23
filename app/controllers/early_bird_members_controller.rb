class EarlyBirdMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @early_bird_members = EarlyBirdMember.active_list.all.order(Arel.sql('lower(name)'))
    update_page_title(t('page.title.earlybird_members'))
  end

  def show
    loading_earlybird_member
    update_page_title(t('page.title.earlybird_member_details'))
  end

  def new
    @early_bird_member = EarlyBirdMember.new
    update_page_title(t('page.title.earlybird_member_add'))
  end

  def edit
    loading_earlybird_member
    update_page_title(t('page.title.earlybird_member_edit'))
  end

  def create
    @early_bird_member = EarlyBirdMember.new(early_bird_member_params)

    if @early_bird_member.save
      flash[:success] = t('page.flash.earlybird_member_created')
      redirect_to @early_bird_member
    else
      render action: 'new'
    end
  end

  def update
    loading_earlybird_member do
      if @early_bird_member.update(early_bird_member_params)
        flash[:success] = t('page.flash.earlybird_member_updated')
        redirect_to @early_bird_member
      else
        render action: 'edit'
      end
    end
  end

  private

  def loading_earlybird_member
    @early_bird_member = EarlyBirdMember.find(params[:id])
    yield if block_given?
  end

  def early_bird_member_params
    params.require(:early_bird_member).permit(:name, :email, :deleted)
  end
end
