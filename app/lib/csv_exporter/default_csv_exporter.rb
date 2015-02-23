class DefaultCSVExporter < CSVExporter
  private
  
  def pqs
    Pq.where('transfer_out_ogd_id is null AND (answer_submitted >= ? OR ' + 
              'answer_submitted is null) AND tabled_date <= ?', @date_to, @date_from)
      .order(:uin)
  end
end