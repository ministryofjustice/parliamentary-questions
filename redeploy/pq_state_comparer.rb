module Redeploy
  class PqStateComparer

    def initialize
      @results = []
    end

    def update_all_states!
      Pq.all.each { |q| q.update_state! }
    end

    def run
      record_set = Pq.joins(:progress).
        where("replace(upper(pqs.state), ' ', '_') != replace(upper(progresses.name), ' ', '_')").
        order(:id)

      record_set.each do |r|
        @results << OpenStruct.new(id: r.id, uin: r.uin, state: r.state, progress: r.progress.name)
      end
      @results
    end

    def display_results
      @results.each do |r|
        puts "#ID: #{r.id}, UIN: #{r.uin}, STATE: #{r.state}  PROGRESS: #{r.progress}"
      end
    end
  end
end