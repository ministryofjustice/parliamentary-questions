module CSVHelpers
  def date_s(d)
    _m = format('%02d', d.month)
    _d = format('%02d', d.day)
    "#{d.year}-#{_m}-#{_d} 00:00"
  end

  def decode_csv(s)
    CSV.new(s, headers: true).to_a.map(&:to_hash)
  end
end
