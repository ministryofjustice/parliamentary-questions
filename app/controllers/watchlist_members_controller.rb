class WatchlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter

  def index
    @watchlist_members = WatchlistMember.all.order('lower(name)')
  end

  def show
    loading_watchlist_member
  end

  def edit
    loading_watchlist_member
  end

  def update
    loading_watchlist_member do
      if @watchlist_member.update(watchlist_member_params)
        redirect_to @watchlist_member, notice: 'Watchlist member was successfully updated.'
      else
        render action: 'edit'
      end
    end
  end

  def new
    @watchlist_member = WatchlistMember.new
  end

  def create
    @watchlist_member = WatchlistMember.new(watchlist_member_params)

    if @watchlist_member.save
      redirect_to @watchlist_member, notice: 'Watchlist member was successfully created.'
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
