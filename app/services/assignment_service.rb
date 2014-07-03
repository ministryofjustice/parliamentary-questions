class AssignmentService

  def accept(assignment)
    assignment.update_attributes(accept: true, reject: false)

    ao = ActionOfficer.find(assignment.action_officer_id)
    pq = PQ.find_by(id: assignment.pq_id)

    pro = Progress.allocated_accepted
    pq.update progress_id: pro.id

    PQAcceptedMailer.commit_email(pq, ao).deliver
  end


  def reject(assignment, response)
    assignment.update_attributes(accept: false, reject: true, reason_option: response.reason_option, reason: response.reason)
    pq = PQ.find_by(id: assignment.pq_id)

    if pq.is_in_progress?(Progress.allocated_accepted)
      return
    end

    pro = Progress.rejected
    pq.update progress_id: pro.id

  end
end