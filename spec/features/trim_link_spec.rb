require 'spec_helper'

feature 'I want to manage trim links' do
  background do
    sign_in
    @pq = create(:pq)
    @pq_with_trim = create(:pq, trim_link: create(:trim_link))
  end

  scenario 'adding a trim link' do
    visit "/pqs/#{@pq.uin}"
    click_link 'Trim link'
    expect(page).not_to have_link 'Open trim link'
    expect(page).to have_content 'Choose trim link'
    attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/trimlink.tr5'))
    click_button 'Save'
    click_link 'Trim link'
    expect(page).to have_link 'Open trim link'
  end

  scenario 'change a trim link' do
    visit "/pqs/#{@pq_with_trim.uin}"
    click_link 'Trim link'
    expect(page).to have_link 'Open trim link'
    expect(page).to have_content 'Change trim link'
    attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/another_trimlink.tr5'))
    click_button 'Save'
    click_link 'Trim link'
    expect(@pq_with_trim.reload.trim_link.filename).to eq('another_trimlink.tr5')
  end

  scenario 'remove a trim link' do
    visit "/pqs/#{@pq_with_trim.uin}"
    click_link 'Trim link'
    click_button 'Delete'
    click_link 'Trim link'
    expect(page).not_to have_link 'Open trim link'
  end

  scenario 'undo a removed trim link' do
    @pq_with_trim.trim_link.archive
    visit "/pqs/#{@pq_with_trim.uin}"
    click_link 'Trim link'
    expect(page).to have_content 'Trim link deleted'
    click_button 'Undo'
    click_link 'Trim link'
    expect(page).to have_link 'Open trim link'
  end

  scenario 'invalid trim link retains other changed fields and previous trim link' do
    visit "/pqs/#{@pq_with_trim.uin}"
    fill_in 'Date for answer back to Parliament', with: '01/01/2001'
    click_link 'Trim link'
    attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/invalid_trimlink.tr5'))
    click_button 'Save'

    expect(page).to have_content 'Trim link data file empty'
    expect(page).to have_field 'Date for answer back to Parliament', with: '01/01/2001'
  end
end
