class ApplyProgressesController < ApplicationController
  before_action :authenticate_user!, PQUserFilter
#  before_action :load_service

  def apply_all
    count_changes = 0

    pqs = Pq.all
    @results = Array.new

    pqs.each do |q|

      begin
        original_status = q.progress.name
        q.progress = Progress.draft_pending

        @results << "#{q.uin} "
        @results << "Interim Progress: #{q.progress.name}"

        #@pq_progress_changer_service.update_progress(q)
        update_progress(q)

        if q.progress.name == 'Draft Pending'
          q.save!
        end
        @results << 'Original Progress: ' + original_status + ' || new status:' + q.progress.name
        count_changes = count_changes + 1 if original_status != q.progress.name
      rescue => e
        @results << "Error : #{e.message}"
      end

      @results << '-------------------------'

    end
    @results
  end

  # def load_service(pq_progress_changer_service = PQProgressChangerService.new)
  #   @pq_progress_changer_service ||= pq_progress_changer_service
  # end


    def update_progress(pq)
      #  initial state 'Draft Pending' (done by the import process)
      with_pod_filter(pq)
      pod_query_filter(pq)
      pod_clearance_filter(pq)
      with_minister_filter(pq)
      minister_query_filter(pq)
      minister_cleared_filter(pq)
      answered_filter(pq)
      transferred_out(pq)
    end

    def with_pod_filter(pq)
      if !pq.draft_answer_received.nil?
        update_pq(pq, Progress.with_pod)
        return
      end
    end

    def pod_query_filter(pq)
      if pq.pod_query_flag
        update_pq(pq, Progress.pod_query)
        return
      end
    end

    def pod_clearance_filter(pq)
      if !pq.pod_clearance.nil?
        update_pq(pq, Progress.pod_cleared)
        return
      end
    end


    def with_minister_filter(pq)
      # does not have policy minister
      if pq.policy_minister.nil?
        if !pq.sent_to_answering_minister.nil?
          update_pq(pq, Progress.with_minister)
          return
        end
      end

      # has policy minister
      if !pq.sent_to_answering_minister.nil? && !pq.sent_to_policy_minister.nil?
        update_pq(pq, Progress.with_minister)
        return
      end
    end

    def minister_query_filter(pq)
      # does not have policy minister
      if pq.policy_minister.nil?
        if pq.answering_minister_query
          update_pq(pq, Progress.ministerial_query)
          return
        end
      end

      # has policy minister
      if pq.policy_minister_query || pq.answering_minister_query
        update_pq(pq, Progress.ministerial_query)
        return
      end
    end


    def minister_cleared_filter(pq)
      # not (with_minister || minister_query)

      # does not have policy minister
      if pq.policy_minister.nil?
        if !pq.cleared_by_answering_minister.nil?
          update_pq(pq, Progress.minister_cleared)
          return
        end
      end

      # has policy minister
      if !pq.cleared_by_answering_minister.nil? && !pq.cleared_by_policy_minister.nil?
        update_pq(pq, Progress.minister_cleared)
        return
      end
    end


    def answered_filter(pq)





      if !pq.pq_withdrawn.nil?
        puts "uin: #{pq.uin} Is Withdrawn: #{pq.pq_withdrawn if !pq.pq_withdrawn.nil?}"
        update_pq(pq, Progress.answered)
        return
      end

      if !pq.answer_submitted.nil?
        puts "uin: #{pq.uin} IS Submitted: #{pq.answer_submitted if !pq.answer_submitted.nil?}"
        update_pq(pq, Progress.answered)
        return
      end

    end

    def transferred_out(pq)
      if !pq.transfer_out_ogd_id.nil? && !pq.transfer_out_date.nil?
        update_pq(pq, Progress.transferred_out)
        return
      end
    end

    def update_pq(pq, progress)
      #pq.update!(progress_id: progress.id)
      pq.progress = progress
      pq.save!

    end

end