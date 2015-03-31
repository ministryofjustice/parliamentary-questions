module Features
  module ReportSpecHelpers


    def create_draft_pending_pq(pq)
      progress_pq_to_draft_pending(pq)
    end

    def create_with_pod_pq(pq)
      pq = @pqs[1]
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
    end

    def create_pod_query_pq(pq)
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
      progress_pq_from_with_pod_to_pod_query(pq)
    end

    def create_pod_cleared_pq_via_pod_query(pq)
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
      progress_pq_from_with_pod_to_pod_query(pq)
      progress_pq_to_pod_cleared(pq)
    end

    def create_pod_cleared_pq(pq)
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
      progress_pq_to_pod_cleared(pq)
    end

    def create_with_minister_pq(pq)
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
      progress_pq_to_pod_cleared(pq)
      progress_pq_from_pod_cleared_to_with_minister(pq)
    end

    def create_answering_minister_query(pq)
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
      progress_pq_to_pod_cleared(pq)
      progress_pq_from_pod_cleared_to_with_minister(pq)
      set_answering_minister_query(pq)
    end

    def create_policy_minister_query(pq)
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
      progress_pq_to_pod_cleared(pq)
      progress_pq_from_pod_cleared_to_with_minister(pq)
      set_policy_minister_query(pq)
    end

    def create_minister_cleared_pq(pq)
      progress_pq_to_draft_pending(pq)
      progress_pq_from_draft_pending_to_with_pod(pq)
      progress_pq_to_pod_cleared(pq)
      progress_pq_from_pod_cleared_to_with_minister(pq)
      set_minister_cleared(pq)
    end





    def set_minister_cleared(pq) 
      in_pq_detail(pq.uin, 'Minister check')  do 
        fillin_date '#cleared_by_answering_minister' 
        fillin_date '#cleared_by_policy_minister'
      end
    end

    def set_policy_minister_query(pq)
      in_pq_detail(pq.uin, 'Minister check')  { check 'Policy minister query' }
    end

    def set_answering_minister_query(pq)
      in_pq_detail(pq.uin, 'Minister check')  { check 'Answering minister query' }
    end 

    def progress_pq_from_pod_cleared_to_with_minister(pq)
      in_pq_detail(pq.uin, 'Minister check')  do
        fillin_date('#sent_to_answering_minister') 
        fillin_date('#sent_to_policy_minister')
      end
    end

    def progress_pq_to_pod_cleared(pq)
      in_pq_detail(pq.uin, 'POD check')  do
        fillin_date('#pod_clearance') 
      end
    end

    def expect_ministers_report_to_have(minister, progress, expected_text)
      visit reports_ministers_by_progress_path
      el = find_table_element_by_minister_and_progress(minister, progress)
      expect(el.text).to eq expected_text
    end


    def progress_pq_from_with_pod_to_pod_query(pq)
      in_pq_detail(pq.uin, 'POD check')  do
        check 'POD query flag'
      end
    end

    def progress_pq_to_draft_pending(pq)
      set_seen_by_finance_check_box(pq)
      commission_question(pq.uin, [action_officer], minister, policy_minister)
      accept_assignment(action_officer)
    end

    def progress_pq_from_draft_pending_to_with_pod(pq)
      in_pq_detail(pq.uin, "PQ draft")       { fillin_date('#draft_answer_received') }
    end

    def find_table_element_by_minister_and_progress(minister, progress)
      selector = %Q<a[href='/reports/filter_all?minister_id=#{minister.id}&progress_id=#{progress.id}']>
      find(selector)
    end

    def set_seen_by_finance_check_box(pq)
      in_pq_detail(pq.uin, 'Finance check')  do
        check 'pq_seen_by_finance'
      end
    end

  end
end