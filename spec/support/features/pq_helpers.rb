module Features
  module PqHelpers
    def commission_question(uin, action_officers, minister, policy_minister = nil)
      create_pq_session
      visit dashboard_path

      within_pq(uin) do
        select_option("commission_form[minister_id]", minister.name)
        select_option("commission_form[policy_minister_id]", policy_minister.name) if policy_minister

        action_officers.each do |ao|
          select ao.name, from: "Action officer(s)"
        end

        find(".answer-date").set Date.tomorrow.strftime("%d/%m/%Y")
        find(".pq-question").click
        find("#internal-deadline input").set Date.tomorrow.strftime("%d/%m/%Y 12:00")
        find(".pq-question").click

        click_on "Commission"
      end
      expect(page).to have_content("#{uin} commissioned successfully")
    end

    def accept_assignment(parliamentary_question, action_officer)
      visit_assignment_url(parliamentary_question, action_officer)
      choose "Accept"
      click_on "Save Response"
    end

    def reject_assignment(parliamentary_question, action_officer, option_index, reason_text)
      visit_assignment_url(parliamentary_question, action_officer)
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
      token_db = FactoryBot.create(:token, path: watchlist_dashboard_path, expire: expiry.end_of_day)
      entity = token_db.entity
      token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire.end_of_day)

      visit watchlist_dashboard_url(token:, entity:)
    end

    def visit_earlybird_url(expiry = Time.zone.now.utc)
      token_db = FactoryBot.create(:token, path: early_bird_dashboard_path, expire: expiry.end_of_day)
      entity = token_db.entity
      token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire)

      visit early_bird_dashboard_url(token:, entity:)
    end

    def visit_assignment_url(parliamentary_question, action_officer)
      pq = Pq.find_by(uin: parliamentary_question.uin)
      ao_pq = ActionOfficersPq.find_by(action_officer_id: action_officer.id, pq_id: parliamentary_question.id)
      token_db = Token.find_by(path: assignment_path(uin: pq.uin.encode), entity: "assignment:#{ao_pq.id}")
      token = TokenService.new.generate_token(token_db.path, token_db.entity, token_db.expire)

      visit assignment_path(uin: pq.uin, token:, entity: token_db.entity)
    end

    def test_date(filter_box, id, date)
      within("#{filter_box}.filter-box") { fill_in id, with: date.strftime("%d/%m/%Y") }
    end

    def test_checkbox(filter_box, category, term)
      within("#{filter_box}.filter-box") do
        find_button(category).click
        choose(term)
        within(".notice") { expect(page.text).to eq("1 selected") }
      end
    end

    def test_keywords(term)
      fill_in "keywords", with: term
    end

    def clear_filter(filter_name)
      find("h1").click
      within("#{filter_name}.filter-box") do
        find_button("Clear").click
        expect(page).not_to have_text("1 selected")
      end
    end

    def all_pqs(number_of_questions, visibility)
      counter = 1
      within(".questions-list") do
        if visibility == "hidden"
          expect(page).not_to have_selector("li")
        else
          while number_of_questions > counter
            id = instance_variable_get("@pq#{counter}").id
            find("li#pq-frame-#{id}").visible?
            counter += 1
          end
        end
      end
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
