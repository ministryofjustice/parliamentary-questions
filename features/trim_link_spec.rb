require 'feature_helper'

feature 'I want to manage trim links', js: true do
  def add_trim_link
    click_link 'Trim link'
    attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/trimlink.tr5'))
    click_button 'Save'
  end

  before(:each) do
    create_pq_session
    @pq, _ = PQA::QuestionLoader.new.load_and_import
  end

  scenario 'adding a trim link' do
    visit "/pqs/#{@pq.uin}"
    expect(page).not_to have_link 'Open trim link'
    add_trim_link
    click_link 'Trim link'
    expect(page).to have_link 'Open trim link'
  end

  scenario 'change a trim link' do
    visit "/pqs/#{@pq.uin}"
    add_trim_link
    click_link 'Trim link'
    expect(page).to have_content 'Change trim link'
    attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/another_trimlink.tr5'))
    click_button 'Save'
    pq = Pq.find_by(uin: @pq.uin)
    expect(pq.trim_link.filename).to eq('another_trimlink.tr5')
  end

  scenario 'remove a trim link' do
    visit "/pqs/#{@pq.uin}"
    add_trim_link
    click_link 'Trim link'
    click_button 'Delete'
    click_link 'Trim link'
    expect(page).not_to have_link 'Open trim link'
  end

  scenario 'undo a removed trim link' do
    visit "/pqs/#{@pq.uin}"
    add_trim_link
    click_link 'Trim link'
    click_button 'Delete'
    click_link 'Trim link'
    expect(page).to have_content 'Trim link deleted'
    click_button 'Undo'
    click_link 'Trim link'
    expect(page).to have_link 'Open trim link'
  end

  #scenario 'invalid trim link retains other changed fields and previous trim link' do
  #  visit "/pqs/#{@pq_with_trim.uin}"
  #  fill_in 'Date for answer back to Parliament', with: '01/01/2001'
  #  click_link 'Trim link'
  #  attach_file('pq[trim_link_attributes][file]', Rails.root.join('spec/fixtures/invalid_trimlink.tr5'))
  #  click_button 'Save'

  #  expect(page).to have_content 'Trim link data file empty'
  #  expect(page).to have_field 'Date for answer back to Parliament', with: '01/01/2001'
  #end
end
