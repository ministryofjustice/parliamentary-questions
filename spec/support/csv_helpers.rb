module CSVHelpers
  def datetime_s(d)
    "#{date_s(d)} 00:00:00 UTC"
  end

  def date_s(d)
    _m = "%02d" % d.month
    _d = "%02d" % d.day
    "#{d.year}-#{_m}-#{_d}"
  end

  def decode_csv(s)
    CSV.new(s, headers: true).to_a.map do |row|
      row.to_hash
    end
  end
end
