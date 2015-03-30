require 'feature_helper'

feature "Parli-branch manages trim link" , js: true do
  include Features::PqHelpers

  def add_trim_link
    click_link 'Trim link'
    attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/trimlink.tr5'))
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

    scenario 'change a trim link' do
      visit pq_path(@pq.uin)
      add_trim_link
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).to have_content 'Change trim link'
      attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/another_trimlink.tr5'))
      click_button 'Save'
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
      attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/invalid_trimlink.tr5'))
      click_button 'Save'
      expect(page.title).to have_text("PQ #{@pq.uin}")
      expect(page).to have_content 'Missing or invalid trim link file'
      expect(page).to have_field 'Date for answer back to Parliament', with: '01/01/2001'
    end
  end

  feature 'from the dashboard' do
    let(:ao1)      { ActionOfficer.find_by(email: 'ao1@pq.com') }
    let(:minister) { Minister.first                             }

    scenario "uploading a valid trim file"
  end
end
