class ArchivesController < ApplicationController
  before_action :authenticate_admin!

  def show
    @archive = Object.new
  end
end
