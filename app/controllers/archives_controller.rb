class ArchivesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_variables

  def new
    update_page_title "Archive PQ Session"
    @archive = Archive.new
  end

  def create
    @archive = Archive.new(archive_params)

    if @archive.valid?
      @archive.save!
      ArchiveService.new(@archive).archive_current

      flash[:success] = "Current session has been archived"
      redirect_to new_archive_path and return
    else
      render :new
    end
  end

  def archive_params
    params.require(:archive).permit(:prefix)
  end

private

  def set_variables
    @all_prefixes = Archive.all_prefixes
    @count = Pq.unarchived.count
  end
end
