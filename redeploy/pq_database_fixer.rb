require "#{Rails.root}/redeploy/pq_state_comparer.rb"
require "#{Rails.root}/redeploy/pq_fixer.rb"

class PqDatabaseFixer

  def run
    comparer = PqStateComparer.new
    comparer.update_all_states!
    results = comparer.run
    results.each do |result|
      pq_fixer = PqFixer.new(result.id)
      pq_fixer.fix!
    end

    # Now see if there are any still in the wrong state
    comparer = PqStateComparer.new
    comparer.run
    comparer.display_results

  end
end