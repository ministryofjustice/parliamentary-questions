class WatchlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @watchlist_members = WatchlistMember.all.order('lower(name)')
    update_page_title('Watchlist members')
  end

  def show
    loading_watchlist_member
    update_page_title('Watchlist member details')
  end

  def edit
    loading_watchlist_member
    update_page_title('Edit watchlist member')
  end

  def update
    loading_watchlist_member do
      if @watchlist_member.update(watchlist_member_params)
        flash[:success] = 'Watchlist member was successfully updated.'
        redirect_to @watchlist_member
      else
        render action: 'edit'
      end
    end
  end

  def new
    @watchlist_member = WatchlistMember.new
    update_page_title('Add watchlist member')
  end

  def create
    @watchlist_member = WatchlistMember.new(watchlist_member_params)

    if @watchlist_member.save
      flash[:success] = 'Watchlist member was successfully created.'
      redirect_to @watchlist_member
    else
      render action: 'new'
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
