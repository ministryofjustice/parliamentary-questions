module Features
  module PqHelpers
    include ::Features::EmailHelpers

    def set_seen_by_finance
      create_finance_session
      click_link_or_button 'btn_finance_visibility'
    end

    def commission_question(uin, action_officers, minister)
      create_pq_session
      visit dashboard_path

      within_pq(uin) do
        select minister.name, from: 'Answering minister'

        action_officers.each do |ao|
          select ao.name, from: 'Action officer(s)'
        end
        find("#internal-deadline input").set Date.tomorrow.strftime('%d/%m/%Y')
        click_on 'Commission'
      end

      expect(page).to have_content("#{@pq.uin} commissioned successfully")
    end

    def accept_assignnment(action_officer)
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

    def expect_pq_status(uin, *click_path)
      visit dashboard_path
      click_path.each do |anchor|
        click_on anchor
      end
      expect(page).to have_content(uin)
    end

    def within_pq(uin)
      within("*[data-pquin='#{uin}']") do
        yield
      end
    end

    private

    def visit_assignment_url(action_officer)
      mail = sent_mail_to(action_officer.email).first
      url  = extract_url_like('/assignment', mail)
      visit url
    end
  end
end
