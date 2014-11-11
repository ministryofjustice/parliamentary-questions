class WatchlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_watchlist_member, only: [:show, :edit, :update, :destroy]

  def index
    @watchlist_members = WatchlistMember.all.order('lower(name)')
  end

  def show
  end

  def new
    @watchlist_member = WatchlistMember.new
  end

  def edit
  end

  def create
    @watchlist_member = WatchlistMember.new(watchlist_member_params)

      if @watchlist_member.save
        redirect_to @watchlist_member, notice: 'Watchlist member was successfully created.'
      else
        render action: 'new'
      end
  end

  def update
      if @watchlist_member.update(watchlist_member_params)
        redirect_to @watchlist_member, notice: 'Watchlist member was successfully updated.'
      else
        render action: 'edit'
      end
  end

private

  def set_watchlist_member
    @watchlist_member = WatchlistMember.find(params[:id])
  end

  def watchlist_member_params
    params.require(:watchlist_member).permit(:name, :email, :deleted)
  end
end
