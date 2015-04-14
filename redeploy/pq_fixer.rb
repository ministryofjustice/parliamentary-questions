

class PqFixer

  def initialize(pqid)
    @pq = Pq.find(pqid)
    @log_messages = []
  end

  def fix!
    # begin
      log("fixing PQID")


      if %w{ unassigned no_response rejected }.include?(@pq.state)
        # for unassigned and no response
        #   create an "Unknown" action officer, with deleted false and assign to question
        #   create ActionOfficersPq object with the question id and action officer id
        #   set ActionOfficersPq response to 'accepted'
        fix_uncommissioned
      end

      if %w{ pod_query with_pod}.include?(@pq.state)
        #   for pod_query, pod_clearance, 
        #   set pod_clearance to answer submitted date
        fix_pod_clearance
      end

      if @pq.state == 'pod_cleared'
        # for pod_cleared
        #   set sent_to_answering_minister to answer_submitted
        #   set sent_to_policy_miniser to answer_submitted if policy_minister not nil
        fix_minister_submitted
      end

      if @pq.state == 'with_minister'
        # for with minister 
        #   when there is a policy minister
        #     set cleared_by_policy_minister to answer_submitted
        fix_cleared_by_policy_minister
      end

      @pq.update_state!
    # rescue => err
      # puts "ERROR: #{err.class}  #{err.message}"
    # ensure
      print_log_messages
    # end
  end

  private

  def log(message)
    @log_messages << "#{@pq.id} UIN: #{@pq.uin} #{message}"
  end

  def print_log_messages
    @log_messages.each { |m| puts m }
  end

  def fix_pod_clearance
    @pq.update!(pod_clearance: @pq.answer_submitted)
    @pq.update_state!
    log("pod_clearance set to #{@pq.pod_clearance}")
  end

  def fix_minister_submitted
    @pq.update!(sent_to_answering_minister: @pq.answer_submitted)
    log("sent_to_answering_minister set to #{@pq.answer_submitted}")

    if @pq.policy_minister
      @pq.update!(sent_to_policy_minister: @pq.answer_submitted)
      log("sent_to_policy_minister set to #{@pq.answer_submitted}")
    end
    @pq.update_state!
  end

  def fix_cleared_by_policy_minister
    @pq.update!(cleared_by_policy_minister: @pq.answer_submitted)
    @pq.update_state!
    log("cleared_by_policy_minister set to #{@pq.answer_submitted}")
  end

  def fix_uncommissioned
    ao_pq = ActionOfficersPq.create(
              pq_id: @pq.id,
              action_officer_id: ao_placeholder.id,
            )

    ao_pq.accept
    @pq.update_state!
    log("assigned to and accepted by ActionOfficer with id: #{ao_placeholder.id}, " + 
        "through ActionOfficersPq with id: #{ao_pq.id} ")
  end

  def ao_placeholder
    @ao_placeholder ||=  
      ActionOfficer.find_or_create_by(
        deputy_director: dd_placeholder, 
        name:            'AO not known placeholder', 
        email:           'pqsupport@digital.justice.gov.uk', 
        press_desk:      PressDesk.first,
        deleted:         true
      )
  end

  def dd_placeholder
    @dd_placeholder ||= 
      DeputyDirector.find_or_create_by(
        division: Division.first,
        email:    'pqsupport@digital.justice.gov.uk',
        name:     'DD for AO not known placeholder',
        deleted:  true
      )
  end
end
