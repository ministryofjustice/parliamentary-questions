class ReportsController < ApplicationController
  def ministers_by_progress
    @p = Progress.all
    @m = Minister.all
    @pq = PQ.in_progress
  end
end
