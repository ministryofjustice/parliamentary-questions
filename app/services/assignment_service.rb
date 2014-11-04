class AssignmentService

  def accept(assignment)


    ao = ActionOfficer.find(assignment.action_officer_id)
    pq = Pq.find_by(id: assignment.pq_id)

    changed_by = "AO:#{ao.name}"

    assignment.whodunnit(changed_by) do
      assignment.update_attributes(accept: true, reject: false)
    end


    div = get_dep_director_for_ao(ao)
    dir = get_directorate_for_ao(ao)

    pro = Progress.accepted

    pq.whodunnit(changed_by) do
      pq.update(progress_id: pro.id, at_acceptance_directorate_id: dir, at_acceptance_division_id: div)
    end
    PqMailer.acceptance_email(pq, ao).deliver
  end


  def reject(assignment, response)

    ao = ActionOfficer.find(assignment.action_officer_id)
    pq = Pq.find_by(id: assignment.pq_id)

    changed_by = "AO:#{ao.name}"

    assignment.whodunnit(changed_by) do
      assignment.update_attributes(accept: false, reject: true, reason_option: response.reason_option, reason: response.reason)
    end

    if pq.action_officers_pq.rejected.size==pq.action_officers_pq.size
      pro = Progress.rejected
    elsif pq.action_officers_pq.accepted.size >=1
      pro = Progress.accepted
    else
      pro = Progress.no_response
    end
    pq.whodunnit(changed_by) do
      pq.update progress_id: pro.id
    end
  end

  private
  def get_dep_director_for_ao(ao)
    ao.deputy_director.division.id if ao.deputy_director && ao.deputy_director.division
  end
  def get_directorate_for_ao(ao)
    ao.deputy_director.division.directorate.id if ao.deputy_director && ao.deputy_director.division && ao.deputy_director.division.directorate
  end
end