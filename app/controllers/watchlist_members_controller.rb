class WatchlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @watchlist_members = WatchlistMember.active_list.all.order(Arel.sql('lower(name)'))
    update_page_title(t('page.title.watchlist_members'))
  end

  def show
    loading_watchlist_member
    update_page_title(t('page.title.watchlist_member_details'))
  end

  def new
    @watchlist_member = WatchlistMember.new
    update_page_title(t('page.title.watchlist_member_add'))
  end

  def edit
    loading_watchlist_member
    update_page_title(t('page.title.watchlist_member_edit'))
  end

  def create
    @watchlist_member = WatchlistMember.new(watchlist_member_params)

    if @watchlist_member.save
      flash[:success] = t('page.flash.watchlist_member_created')
      redirect_to @watchlist_member
    else
      render action: 'new'
    end
  end

  def update
    loading_watchlist_member do
      if @watchlist_member.update(watchlist_member_params)
        flash[:success] = t('page.flash.watchlist_member_updated')
        redirect_to @watchlist_member
      else
        render action: 'edit'
      end
    end
  end

  private

  def loading_watchlist_member
    @watchlist_member = WatchlistMember.find(params[:id])
    yield if block_given?
  end

  def watchlist_member_params
    params.require(:watchlist_member).permit(:name, :email, :deleted)
  end
end
