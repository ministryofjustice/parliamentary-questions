module SoftDeletion
  module Collection
    def active
      where(deleted: false)
    end

    def inactive
      where(deleted: true)
    end
  end

  module Record
    def activate!
      update(deleted: false)
    end

    def deactivate!
      update(deleted: true)
    end
  end
end
