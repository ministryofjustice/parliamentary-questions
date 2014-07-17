class ActionlistMembersController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
  before_action :set_actionlist_member, only: [:show, :edit, :update, :destroy]

  def index
    @actionlist_members = ActionlistMember.all
  end

  def show
  end

  def new
    @actionlist_member = ActionlistMember.new
  end


  def edit
  end

  def create
    @actionlist_member = ActionlistMember.new(actionlist_member_params)

    if @actionlist_member.save
      redirect_to @actionlist_member, notice: 'Actionlist member was successfully created.'
    else
      render action: 'new'
    end

  end

  def update
      if @actionlist_member.update(actionlist_member_params)
        redirect_to @actionlist_member, notice: 'Actionlist member was successfully updated.'
      else
        render action: 'edit'
      end
  end

  def destroy
    @actionlist_member.destroy
    redirect_to actionlist_members_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_actionlist_member
      @actionlist_member = ActionlistMember.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def actionlist_member_params
      params.require(:actionlist_member).permit(:name, :email, :deleted)
    end
end
