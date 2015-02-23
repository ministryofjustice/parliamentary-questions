module Export
  class PqPod < Base
    private

    def pqs
      Pq.where('tabled_date >= ? AND tabled_date <= ? AND draft_answer_received ' +
               'is not null AND pod_clearance is null and answer_submitted is null', 
               @date_to, @date_from)
        .order(:date_for_answer)
    end
  end
end
