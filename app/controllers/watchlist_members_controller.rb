class WatchlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_watchlist_member, only: [:show, :edit, :update, :destroy]

  # GET /watchlist_members
  # GET /watchlist_members.json
  def index
    @watchlist_members = WatchlistMember.all.order('lower(name)')
  end

  # GET /watchlist_members/1
  # GET /watchlist_members/1.json
  def show
  end

  # GET /watchlist_members/new
  def new
    @watchlist_member = WatchlistMember.new
  end

  # GET /watchlist_members/1/edit
  def edit
  end

  # POST /watchlist_members
  def create
    @watchlist_member = WatchlistMember.new(watchlist_member_params)

      if @watchlist_member.save
        redirect_to @watchlist_member, notice: 'Watchlist member was successfully created.'
      else
        render action: 'new'
      end
  end

  # PATCH/PUT /watchlist_members/1
  def update
      if @watchlist_member.update(watchlist_member_params)
        redirect_to @watchlist_member, notice: 'Watchlist member was successfully updated.'
      else
        render action: 'edit'
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_watchlist_member
      @watchlist_member = WatchlistMember.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def watchlist_member_params
      params.require(:watchlist_member).permit(:name, :email, :deleted)
    end
end
