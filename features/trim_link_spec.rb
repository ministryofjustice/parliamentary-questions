require 'feature_helper'

feature "Parli-branch manages trim link" , js: true do
  include Features::PqHelpers

  def add_trim_link(trim_file_name = 'spec/fixtures/trimlink.tr5')
    click_link 'Trim link'
    # We need to make the file <input> visible, otherwise it won't pick up attach_file later (see below)
    page.execute_script('$("input[type=file]").attr("style","display:inline!important")')
    attach_file('pq[trim_link_attributes][file]', Rails.root.join(trim_file_name))
    page.execute_script('$("input[type=file]").attr("style","")')
    click_button 'Save'
    click_link 'Trim link'
  end

  before(:each) do
    DBHelpers.load_feature_fixtures
    @pq, _ = PQA::QuestionLoader.new.load_and_import
    set_seen_by_finance
    create_pq_session
  end

  feature 'from the details view' do
    scenario 'add a trim link' do
      visit pq_path(@pq.uin)
      expect(page).not_to have_link 'Open trim link'
      add_trim_link
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).to have_link 'Open trim link'
    end

    scenario 'select a trim file too big' do
      visit pq_path(@pq.uin)
      click_link 'Trim link'
      page.execute_script('$("input[type=file]").attr("style","display:inline!important")')
      attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/trimlink_too_large.tr5'))
      page.execute_script('$("input[type=file]").attr("style","")')

      expect(page).to have_content 'This file is too large'
      expect(page).to have_css 'span.fa-warning'
    end

    scenario 'change a trim link' do
      visit pq_path(@pq.uin)
      add_trim_link
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).to have_content 'Change trim link'
      add_trim_link('spec/fixtures/another_trimlink.tr5')
      pq = Pq.find_by(uin: @pq.uin)
      expect(pq.trim_link.filename).to eq('another_trimlink.tr5')
    end

    scenario 'remove a trim link' do
      visit pq_path(@pq.uin)
      add_trim_link
      click_button 'Delete'
      click_link 'Trim link'
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).not_to have_link 'Open trim link'
    end

    scenario 'undo a removed trim link' do
      visit pq_path(@pq.uin)
      add_trim_link
      click_button 'Delete'
      click_link 'Trim link'
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).to have_content 'Trim link deleted'
      click_button 'Undo'
      click_link 'Trim link'
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).to have_link 'Open trim link'
    end

    scenario 'invalid trim link retains other changed fields and previous trim link' do
      visit pq_path(@pq.uin)
      add_trim_link
      click_link 'PQ Details'
      fill_in 'Date for answer back to Parliament', with: '01/01/2001'
      click_link 'Trim link'
      add_trim_link('spec/fixtures/invalid_trimlink.tr5')
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).to have_content 'Invalid file selected!'
      click_link 'PQ Details'
      expect(page).to have_field 'Date for answer back to Parliament', with: '01/01/2001'
    end
  end

  feature 'from the dashboard', js: true do
    let(:ao1)      { ActionOfficer.find_by(email: 'ao1@pq.com') }
    let(:minister) { Minister.first                             }

    def select_file_to_upload(filename)
      # We need to make the file <input> visible, otherwise it won't pick up attach_file later
      # Not sure why it's not enough to use ignore_hidden_elements above.
      # Probably a bug with capybara/phantomjs
      page.execute_script('$(".trim-file-chooser").attr("style","display:inline!important")')
      page.execute_script('$(".toggle-content").attr("style","display:block!important")')

      attach_file('trim_link[file_data]', Rails.root.join(filename))

      page.execute_script('$(".trim-file-chooser").attr("style","display:inline")')
      page.execute_script('$(".toggle-content").attr("style","display:block")')
    end

    before(:each) do
      create_pq_session
      visit dashboard_path
    end

    scenario 'server error when uploading a trim' do
      expect_any_instance_of(TrimLinksController).to receive(:create).and_raise(RuntimeError)
      select_file_to_upload 'spec/fixtures/trimlink.tr5'
      click_button 'Upload'
      expect(page).to have_content('Server error')
    end

    scenario 'selecting a file to upload to trim'  do
      select_file_to_upload 'spec/fixtures/trimlink.tr5'
      expect(page).to have_content 'File selected'
      expect(page).to have_css 'span.fa-file-o'
    end

    scenario 'cancel after selecting' do
      select_file_to_upload 'spec/fixtures/trimlink.tr5'
      click_button 'Cancel'
      expect(page).to have_css 'button.button-choose'
      expect(page).not_to have_css 'button.button-cancel'
    end

    scenario 'upload a file after selecting' do
      select_file_to_upload 'spec/fixtures/trimlink.tr5'
      click_button 'Upload'
      expect(page).to have_content 'Trim link created'
      expect(page).to have_css 'span.fa-check-circle'
      expect(page).to have_content 'Open trim link'
    end

    scenario 'upload an invalid file to trim' do
      select_file_to_upload 'spec/fixtures/invalid_trimlink.tr5'
      click_button 'Upload'
      expect(page).to have_content 'Invalid file selected!'
      expect(page).to have_css 'span.fa-warning'
    end

    scenario 'select a too big file to trim' do
      select_file_to_upload 'spec/fixtures/trimlink_too_large.tr5'
      expect(page).to have_content 'This file is too large'
      expect(page).to have_css 'span.fa-warning'
    end

    scenario 'After trying to upload an invalid file, try to upload another file' do
      select_file_to_upload 'spec/fixtures/invalid_trimlink.tr5'
      click_button 'Upload'
      expect(page).to have_content 'Invalid file selected!'
      click_button 'Cancel'
      select_file_to_upload 'spec/fixtures/trimlink.tr5'
      click_button 'Upload'

      expect(page).to have_content 'Trim link created'
      expect(page).to have_css 'span.fa-check-circle'
      expect(page).to have_content 'Open trim link'
    end

  end
end
