module Export
  class PqPod < Base
    private

    def pqs
      Pq.where('tabled_date >= ? AND tabled_date <= ? AND draft_answer_received ' +
               'IS NOT null AND pod_clearance IS null AND answer_submitted IS null', 
               @date_from, @date_to)
        .order(:date_for_answer)
    end
  end
end
