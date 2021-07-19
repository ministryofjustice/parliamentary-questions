class AssignmentService
  def accept(assignment)
    pq = assignment.pq

    changed_by = "AO:#{assignment.action_officer.name}"

    PaperTrail.request(whodunnit: changed_by) do
      assignment.accept
    end

    PaperTrail.request(whodunnit: changed_by) do
      division = assignment.action_officer.deputy_director.try(:division)
      directorate = division.try(:directorate)
      pq.update(directorate: directorate, original_division: division)
    end
    pq.update_state!
    if assignment.action_officer.group_email.present?
      NotifyPqMailer.acceptance_email(pq: pq, action_officer: assignment.action_officer, email: assignment.action_officer.group_email).deliver_later
    end
    NotifyPqMailer.acceptance_email(pq: pq, action_officer: assignment.action_officer, email: assignment.action_officer.email).deliver_later
  end

  def reject(assignment, response)
    pq = assignment.pq

    changed_by = "AO:#{assignment.action_officer.name}"

    PaperTrail.request(whodunnit: changed_by) do
      assignment.reject(response.reason_option, response.reason)
    end

    pq.update_state!
  end
end
