class DupeDeputyDirectorFixer

  def initialize(dupes)
    @dupes = dupes
    @reports = []
  end

  def dedupe!
    aos = ActionOfficer.where('deputy_director_id in (?)', @dupes.keys)
    aos.each do |ao|
      if @dupes.keys.include?(ao.deputy_director_id)
        old_dd = ao.deputy_director
        new_dd = DeputyDirector.find(@dupes[old_dd.id])
        ao.update_attribute(:deputy_director, new_dd)
        @reports << "AO:#{ao.id} #{ao.name} has changed DD from #{old_dd.id}:#{old_dd.name} to #{new_dd.id}:#{new_dd.name}."
      end
    end
  end

end
