module RakeTaskHelpers
  # Keep all those questions which have been assigned
  # Only keep 50 most-recent and unassigned questions
  class DBTrim
    def run!
      max_limit = 50
      total_count = Pq.where(state: 'unassigned').size
      if total_count > max_limit
        ids_kept = Pq.where(state: 'unassigned').order(created_at: :desc).limit(max_limit).ids
        Pq.where(state: 'unassigned').where.not(id: ids_kept).map(&:destroy)
      end
    end
  end
end
