class ArchiveService
  def initialize(archive)
    @archive = archive
  end

  def archive_current
    raise InvalidArchiveError, "Archive with prefix #{@archive.prefix} is invalid" if @archive.invalid?

    Pq.unarchived.update_all("uin='#{@archive.prefix}'||uin")
    Pq.unarchived.update_all("archived = true")
  end
end

class InvalidArchiveError < StandardError
end
