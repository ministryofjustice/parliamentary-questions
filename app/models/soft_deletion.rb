module SoftDeletion
  def active
    where(deleted: false)
  end

  def inactive
    where(deleted: true)
  end
end
