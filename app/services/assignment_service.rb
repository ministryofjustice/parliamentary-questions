class AssignmentService
  def accept(assignment)
    pq = assignment.pq

    changed_by = "AO:#{assignment.action_officer.name}"

    assignment.whodunnit(changed_by) do
      assignment.accept
    end

    pq.whodunnit(changed_by) do
      division = assignment.action_officer.deputy_director.try(:division)
      directorate = division.try(:directorate)
      pq.update(directorate: directorate, division: division)
    end
    update_progress(pq)
    PqMailer.acceptance_email(pq, assignment.action_officer).deliver
  end

  def reject(assignment, response)
    pq = assignment.pq

    changed_by = "AO:#{assignment.action_officer.name}"

    assignment.whodunnit(changed_by) do
      assignment.reject(response.reason_option, response.reason)
    end

    update_progress(pq)
  end

private

  def update_progress(pq)
    PQProgressChangerService.new.update_progress(pq)
  end
end
