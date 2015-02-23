module Export
  class PqDefault < Base
    private
    def pqs
      Pq.where(
        'transfer_out_ogd_id is null AND (answer_submitted >= ? OR ' + 
        'answer_submitted is null) AND tabled_date <= ?', @date_from, @date_to)
        .order(:uin)
    end
  end
end
