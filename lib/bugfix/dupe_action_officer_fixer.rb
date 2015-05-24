class DupeActionOfficerFixer


  #expects a hash { a => x, b => y, c => z } where a, b, c are the current ao_ids, and x, y, z are what they must be replaced with
  def initialize(dupes)
    @dupes = dupes
    @report = []
  end

  def dedupe!
    aopqs = find_aopqs
    aopqs.each do |aopq|
      if @dupes.keys.include?(aopq.action_officer_id)
        old_ao = aopq.action_officer
        aopq.update_attribute(:action_officer_id, @dupes[old_ao.id])
        @report << "PQ #{aopq.pq.uin} AO #{old_ao.id}:#{old_ao.name} replaced with AO #{aopq.action_officer_id}:#{aopq.action_officer.name}."
      end
    end
  end

  def report
    @report.each { |r| puts r }
  end


  private

  def find_aopqs
    ActionOfficersPq.where('action_officer_id in (?)', @dupes.keys )
  end




end


