require 'csv'

class PqDivisionFixer

  DIVISIONS_FILE = '/Users/stephen/tmp/division_changes.csv'

  def initialize
    @data = CSV.read(DIVISIONS_FILE)
    @data.shift       # remove header row
    @report = []
  end

  def fix!
    @data.each { |row| process_row(row) }
    nil
  end

  def report
    @report.each { |r| puts r }
  end


  private

  def process_row(row)
    id, uin, id, name, pq_div_id, pq_div_name, ao_div_id, ao_div_name, correct_division = row
    return if correct_division.nil?
    update_pq(uin, ao_div_name) if correct_division.strip.upcase == 'CURRENT'
  end


  def update_pq(uin, div_name)
    pq = Pq.uin(uin)
    raise "Unable to find UIN #{uin}" if pq.nil?
    if pq.action_officers.accepted.nil?
      @report << ">>>> ERROR UIN #{uin} - no accepted action officer!"
      return
    end

    new_div = pq.action_officers.accepted.deputy_director.division
    @report << "Changed UIN #{uin} from Div #{pq.original_division_id}:#{pq.original_division.name} to #{new_div.id}:#{new_div.name}"
    if new_div.name.strip != div_name.strip
      @report << ">> Warning: name mismatch"
      @report << "   Expected: #{div_name}"
      @report << "   Got:      #{new_div.name}"
    end
    pq.update_attribute(:original_division, new_div)
  end


end