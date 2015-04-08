module Features
  module PqHelpers
    include ::Features::EmailHelpers

    def set_seen_by_finance
      create_finance_session
      click_link_or_button 'btn_finance_visibility'
    end

    def commission_question(uin, action_officers, minister, policy_minister = nil)
      create_pq_session
      visit dashboard_path

      within_pq(uin) do
        select_option('commission_form[minister_id]', minister.name)
        select_option('commission_form[policy_minister_id]', policy_minister.name) if policy_minister

        action_officers.each do |ao|
          select ao.name, from: 'Action officer(s)'
        end
        find("#internal-deadline input").set Date.tomorrow.strftime('%d/%m/%Y')
        click_on 'Commission'
      end

      expect(page).to have_content("#{uin} commissioned successfully")
    end

    def accept_assignment(action_officer)
      visit_assignment_url(action_officer)
      choose 'Accept'
      click_on 'Save Response'
    end

    def reject_assignment(action_officer, option_index, reason_text)
      visit_assignment_url(action_officer)
      choose 'Reject'

      find('select[name="allocation_response[reason_option]"]')
        .find(:xpath, "option[#{option_index}]")
        .select_option

      fill_in 'allocation_response_reason', with: reason_text
      click_on 'Save Response'
    end

    def expect_pq_status(uin, status)
      visit dashboard_path unless page.current_path == dashboard_path
      click_on status
      expect(page).to have_content(uin)
    end

    def expect_pq_in_progress_status(uin, status)
      visit dashboard_in_progress_path unless page.current_path == dashboard_in_progress_path
      click_on status
      expect(page).to have_content(uin)
    end

    def within_pq(uin)
      within("*[data-pquin='#{uin}']") do
        yield
      end
    end

    def in_pq_detail(uin, section_anchor)
      visit pq_path(uin) unless page.current_path == pq_path(uin)
      click_on section_anchor
      yield
      click_on "Save"
    end

    private

    def select_option(selector_name, option_text)
      find(:select, selector_name)
            .find(:option, text: option_text)
            .select_option
    end

    def visit_assignment_url(action_officer)
      mail = sent_mail_to(action_officer.email).first
      url  = extract_url_like('/assignment', mail)
      visit url
    end

    def fillin_date(css_sel)
      find(css_sel).set(Date.today.strftime('%d/%m/%Y'))
    end

  end
end
