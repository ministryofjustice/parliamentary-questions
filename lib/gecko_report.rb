require 'json'
class GeckoReport
  def initialize
    @commons  = Pq.commons.count
    @lords = Pq.lords.count
    @ordinary = Pq.ordinary.count
    @named_day = Pq.named_day.count
    @commons_this_week  = Pq.commons.imported_this_week.count
    @commons_last_week  = Pq.commons.imported_last_week.count

    @commons_this_week_ordinary  = Pq.commons.imported_this_week.ordinary.count
    @commons_last_week_named_day  = Pq.commons.imported_last_week.named_day.count

    @lords_this_week_ordinary = Pq.lords.imported_this_week.ordinary.count
    @lords_last_week_ordinary = Pq.lords.imported_last_week.ordinary.count

    @answered_by_deadline_last_week = Pq.answered_by_deadline_last_week.count

    @hoc_ord_ans_by_dead_last_week = Pq.commons.ordinary.answered_by_deadline_last_week.count
    @hoc_nmd_ans_by_dead_last_week = Pq.commons.named_day.answered_by_deadline_last_week.count
    @hol_ord_ans_by_dead_last_week = Pq.lords.ordinary.answered_by_deadline_last_week.count

    @hoc_ord_ans_by_dead_ytd = Pq.commons.ordinary.answered_by_deadline_ytd.count
    @hoc_nmd_ans_by_dead_ytd = Pq.commons.named_day.answered_by_deadline_ytd.count
    @hol_ord_ans_by_dead_ytd = Pq.lords.ordinary.answered_by_deadline_ytd.count


    @answered_by_deadline_ytd = Pq.answered_by_deadline_ytd.count

    @draft_response_on_time_ytd = Pq.draft_response_on_time_ytd.count
  end


end
