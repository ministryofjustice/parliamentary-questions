module CSVHelpers
  def date_s(date)
    _m = sprintf("%02d", date.month)
    _d = sprintf("%02d", date.day)
    "#{date.year}-#{_m}-#{_d} 00:00"
  end

  def decode_csv(csv_file)
    CSV.new(csv_file, headers: true).to_a.map(&:to_hash)
  end
end
