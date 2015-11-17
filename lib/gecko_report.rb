require 'json'
class GeckoReport
  def initialize
    @gecko_report = []
    @by_directorate = []
    @ministerial = []

    write_report
    add_directorate_data
    add_ministerial_data
  end

  def write_report
    add_item('total_questions_ytd', Pq.total_questions_ytd.count)

    add_item('import_commons_last_week_ordinary', Pq.commons.imported_last_week.ordinary.count)
    add_item('import_commons_prev_week_ordinary', Pq.commons.imported_prev_week.ordinary.count)

    add_item('import_commons_last_week_named_day', Pq.commons.imported_last_week.named_day.count)
    add_item('import_commons_prev_week_named_day', Pq.commons.imported_prev_week.named_day.count)

    add_item('import_commons_last_week', Pq.commons.imported_last_week.count)
    add_item('import_commons_prev_week', Pq.commons.imported_prev_week.count)


    add_item('import_lords_last_week_ordinary', Pq.lords.imported_last_week.ordinary.count)
    add_item('import_lords_prev_week_ordinary', Pq.lords.imported_prev_week.ordinary.count)

    add_item('hoc_ord_ans_by_dead_last_week', Pq.commons.ordinary.answered_by_deadline_last_week.count)
    add_item('hoc_nmd_ans_by_dead_last_week', Pq.commons.named_day.answered_by_deadline_last_week.count)
    add_item('hol_ord_ans_by_dead_last_week', Pq.lords.ordinary.answered_by_deadline_last_week.count)
    add_item('answered_by_deadline_last_week', Pq.answered_by_deadline_last_week.count)

    add_item('hoc_ord_ans_last_week', Pq.commons.ordinary.answered_last_week.count)
    add_item('hoc_nmd_ans_last_week', Pq.commons.named_day.answered_last_week.count)
    add_item('hol_ord_ans_last_week', Pq.lords.ordinary.answered_last_week.count)

    add_item('hoc_ord_ans_by_dead_ytd', Pq.commons.ordinary.answered_by_deadline_ytd.count)
    add_item('hoc_nmd_ans_by_dead_ytd', Pq.commons.named_day.answered_by_deadline_ytd.count)
    add_item('hol_ord_ans_by_dead_ytd', Pq.lords.ordinary.answered_by_deadline_ytd.count)

    add_item('hoc_ord_ans_ytd', Pq.commons.ordinary.answered_ytd.count)
    add_item('hoc_nmd_ans_ytd', Pq.commons.named_day.answered_ytd.count)
    add_item('hol_ord_ans_ytd', Pq.lords.ordinary.answered_ytd.count)


    add_item('answered_by_deadline_ytd', Pq.answered_by_deadline_ytd.count)

    add_item('draft_response_on_time_ytd', Pq.draft_response_on_time_ytd.count)

    add_item('answered_ytd', Pq.answered_ytd.count)
  end

  def add_item(name, value)
   item = {:name => name, :value => value}
   @gecko_report << item
  end

  def add_directorate_data
    directorate_return = []
    directorate_return << Pq.joins(:directorate).group("name").draft_response_on_time_ytd.count
    @by_directorate = directorate_return[0].map{|key,value| {:name => key, :value => value} }
  end

  def add_ministerial_data
    ministerial_return = []
    ministerial_return << Pq.joins(:minister).group("name").answered_by_deadline_ytd.count
    @ministerial = ministerial_return[0].map{|key,value| {:name => key, :value => value} }
  end
end
