module Features
  module PqHelpers
    def set_seen_by_finance
      create_finance_session
      click_link_or_button "btn_finance_visibility"
    end

    def commission_question(uin, action_officers, minister, policy_minister = nil)
      create_pq_session
      visit dashboard_path

      within_pq(uin) do
        select_option("commission_form[minister_id]", minister.name)
        select_option("commission_form[policy_minister_id]", policy_minister.name) if policy_minister

        action_officers.each do |ao|
          select ao.name, from: "Action officer(s)"
        end
        find("#internal-deadline input").set Date.tomorrow.strftime("%d/%m/%Y 12:00")
        click_on "Commission"
      end
      expect(page).to have_content("#{uin} commissioned successfully")
    end

    def accept_assignment(pq, ao)
      visit_assignment_url(pq, ao)
      choose "Accept"
      click_on "Save Response"
    end

    def reject_assignment(pq, ao, option_index, reason_text)
      visit_assignment_url(pq, ao)
      choose "Reject"

      find('select[name="allocation_response[reason_option]"]')
        .find(:xpath, "option[#{option_index}]")
        .select_option

      fill_in "allocation_response_reason", with: reason_text
      click_on "Save Response"
    end

    def expect_pq_status(uin, status)
      visit dashboard_path unless page.current_path == dashboard_path
      expect(page).to have_content(uin)
      expect_pq_to_be_in_state(uin, status)
      # Return page to dashboard
      visit dashboard_path unless page.current_path == dashboard_path
    end

    def expect_pq_in_progress_status(uin, status)
      visit dashboard_in_progress_path unless page.current_path == dashboard_in_progress_path
      expect(page).to have_content(uin)
      expect_pq_to_be_in_state(uin, status)
    end

    def expect_pq_to_be_in_state(uin, status)
      visit pq_path(uin) unless page.current_path == pq_path(uin)
      expect(page).to have_content(status)
    end

    def within_pq(uin, &block)
      within("*[data-pquin='#{uin}']", &block)
    end

    def in_pq_detail(uin, section_anchor)
      visit pq_path(uin) unless page.current_path == pq_path(uin)
      click_on section_anchor
      yield
      click_on "Save"
    end

    def visit_watchlist_url(expiry = Time.zone.now.utc)
      token_db = Token.find_by(path: watchlist_dashboard_path, expire: expiry.end_of_day)
      entity = token_db.entity
      token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire.end_of_day)

      visit watchlist_dashboard_url(token:, entity:)
    end

    def visit_earlybird_url(expiry = Time.zone.now.utc)
      token_db = Token.find_by(path: early_bird_dashboard_path, expire: expiry.end_of_day)
      entity = token_db.entity
      token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire)

      visit early_bird_dashboard_url(token:, entity:)
    end

    def visit_assignment_url(pq, ao)
      pq = Pq.find_by(uin: pq.uin)
      ao_pq = ActionOfficersPq.find_by(action_officer_id: ao.id, pq_id: pq.id)
      token_db = Token.find_by(path: assignment_path(uin: pq.uin.encode), entity: "assignment:#{ao_pq.id}")
      token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire)

      visit assignment_path(uin: pq.uin, token:, entity: token_db.entity)
    end

  private

    def select_option(selector_name, option_text)
      find(:select, selector_name)
        .find(:option, text: option_text)
        .select_option
    end

    def fillin_date(css_sel)
      find(css_sel).set(Time.zone.today.strftime("%d/%m/%Y"))
    end
  end
end
