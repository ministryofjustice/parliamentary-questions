module CSVHelpers
  def date_s(date)
    month = sprintf("%02d", date.month)
    day = sprintf("%02d", date.day)
    "#{date.year}-#{month}-#{day} 00:00"
  end

  def decode_csv(csv_file)
    CSV.new(csv_file, headers: true).to_a.map(&:to_hash)
  end
end
