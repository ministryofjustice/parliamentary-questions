module PqCounts
  # Returns a hash of PQ counts by state
  #
  # @returns [Hash[String, Fixnum]]
  #
  def counts_by_state
    state_counts =
      select("state", "count(*)")
      .group("state")
      .reduce({}) { |acc, r| acc.merge(r.state => r.count) }

    state_counts.merge(
      "view_all" => Pq.new_questions.count,
      "view_all_in_progress" => Pq.in_progress.count,
      "transferred_in" => Pq.transferred.count,
    )
  end
end
