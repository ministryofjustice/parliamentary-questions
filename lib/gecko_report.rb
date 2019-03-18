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
    add_item('total_questions_since', Pq.total_questions_since.count)

    add_item('commons_due_last_week_ordinary', Pq.commons.due_last_week.ordinary.count)
    add_item('commons_due_prev_week_ordinary', Pq.commons.due_prev_week.ordinary.count)

    add_item('commons_last_week_named_day', Pq.commons.due_last_week.named_day.count)
    add_item('commons_prev_week_named_day', Pq.commons.due_prev_week.named_day.count)

    add_item('commons_due_last_week', Pq.commons.due_last_week.count)
    add_item('commons_due_prev_week', Pq.commons.due_prev_week.count)

    add_item('lords_due_last_week_ordinary', Pq.lords.due_last_week.ordinary.count)
    add_item('lords_due_prev_week_ordinary', Pq.lords.due_prev_week.ordinary.count)

    add_item('hoc_ord_due_last_week_on_time', Pq.commons.ordinary.due_last_week.on_time.count)
    add_item('hoc_nmd_due_last_week_on_time', Pq.commons.named_day.due_last_week.on_time.count)
    add_item('hol_ord_due_last_week_on_time', Pq.lords.ordinary.due_last_week.on_time.count)

    add_item('answered_by_deadline_last_week', Pq.answered_by_deadline_last_week.count)

    add_item('hoc_ord_ans_last_week - Deprecated', Pq.commons.ordinary.answered_last_week.count)
    add_item('hoc_nmd_ans_last_week - Deprecated', Pq.commons.named_day.answered_last_week.count)
    add_item('hol_ord_ans_last_week - Deprecated', Pq.lords.ordinary.answered_last_week.count)

    add_item('hoc_ord_ans_by_dead_since', Pq.commons.ordinary.answered_by_deadline_since.count)
    add_item('hoc_nmd_ans_by_dead_since', Pq.commons.named_day.answered_by_deadline_since.count)
    add_item('hol_ord_ans_by_dead_since', Pq.lords.ordinary.answered_by_deadline_since.count)

    add_item('hoc_ord_ans_since', Pq.commons.ordinary.answered_since.count)
    add_item('hoc_nmd_ans_since', Pq.commons.named_day.answered_since.count)
    add_item('hol_ord_ans_since', Pq.lords.ordinary.answered_since.count)

    add_item('answered_by_deadline_since', Pq.answered_by_deadline_since.count)

    add_item('draft_response_on_time_since', Pq.draft_response_on_time_since.count)

    add_item('answered_since', Pq.answered_since.count)

    add_item('due_last_week', Pq.due_last_week.count)
    add_item('due_prev_week', Pq.due_prev_week.count)

    add_item('due_last_week_answered_on_time', Pq.due_last_week.on_time.count)
  end

  def add_item(name, value)
    item = { name: name, value: value }
    @gecko_report << item
  end

  def add_directorate_data
    directorate_return = []
    directorate_return << Pq.joins(:original_division).group('name').draft_response_on_time_since.count
    @by_directorate = directorate_return[0].map { |key, value| { name: 'draft on time-' + key, value: value } }
    directorate_questions = []
    directorate_questions << Pq.joins(:original_division).group('name').draft_response_due_since.count
    @by_directorate += directorate_questions[0].map { |key, value| { name: 'draft due since-' + key, value: value } }
    # draft_response_due_since
  end

  def add_ministerial_data
    ministerial_return = []
    ministerial_return << Pq.joins(:minister).group('name').answered_by_deadline_since.count
    @ministerial = ministerial_return[0].map { |key, value| { name: 'answered by deadline-' + key, value: value } }
    ministerial_questions = []
    ministerial_questions << Pq.joins(:minister).group('name').answer_due_since.count
    @ministerial += ministerial_questions[0].map { |key, value| { name: 'due since-' + key, value: value } }
  end
end
