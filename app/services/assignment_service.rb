class AssignmentService

  def accept(assignment)
    assignment.update_attributes(accept: true, reject: false)

    ao = ActionOfficer.find(assignment.action_officer_id)
    pq = Pq.find_by(id: assignment.pq_id)


    div = ao.deputy_director.division.id if ao.deputy_director && ao.deputy_director.division
    dir = ao.deputy_director.division.directorate.id if ao.deputy_director && ao.deputy_director.division && ao.deputy_director.division.directorate

    pro = Progress.accepted
    pq.update progress_id: pro.id, at_acceptance_directorate_id: dir, at_acceptance_division_id: div

    PQAcceptedMailer.commit_email(pq, ao).deliver
  end


  def reject(assignment, response)
    assignment.update_attributes(accept: false, reject: true, reason_option: response.reason_option, reason: response.reason)
    pq = Pq.find_by(id: assignment.pq_id)

    if pq.action_officers_pq.rejected.size==pq.action_officers_pq.size
      pro = Progress.rejected
      pq.update progress_id: pro.id
      return
    end

    if pq.action_officers_pq.accepted.size >=1
      pro = Progress.accepted
      pq.update progress_id: pro.id
      return
    end

    pro = Progress.no_response
    pq.update progress_id: pro.id
  end
end