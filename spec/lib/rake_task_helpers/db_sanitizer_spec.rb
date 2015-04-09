require 'spec_helper'
require "#{Rails.root}/lib/rake_task_helpers/db_sanitizer.rb"

describe RakeTaskHelpers::DBSanitizer do
  it 'should sanitize email in the selected tables of the database' do
    ao  = FactoryGirl.create(:action_officer)
    alm = FactoryGirl.create(:actionlist_member)
    dd  = FactoryGirl.create(:deputy_director)
    mc  = FactoryGirl.create(:minister_contact)
    po  = FactoryGirl.create(:press_officer)
    u   = FactoryGirl.create(:user)
    wlm = FactoryGirl.create(:watchlist_member)

    RakeTaskHelpers::DBSanitizer.new.run!

    expect(ao.reload.email).to eq "pqsupport+ao#{ao.id}@digital.justice.gov.uk"
    expect(alm.reload.email).to eq "pqsupport+alm#{alm.id}@digital.justice.gov.uk"
    expect(dd.reload.email).to eq "pqsupport+dd#{dd.id}@digital.justice.gov.uk"
    expect(mc.reload.email).to eq "pqsupport+mc#{mc.id}@digital.justice.gov.uk"
    expect(po.reload.email).to eq "pqsupport+po#{po.id}@digital.justice.gov.uk"
    expect(u.reload.email).to eq "pqsupport+u#{u.id}@digital.justice.gov.uk"
    expect(wlm.reload.email).to eq "pqsupport+wlm#{wlm.id}@digital.justice.gov.uk"
  end 
end