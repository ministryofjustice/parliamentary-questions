require 'spec_helper'
require "#{Rails.root}/lib/rake_task_helpers/db_sanitizer.rb"

describe RakeTaskHelpers::DBSanitizer do
  it 'should sanitize email in the selected tables of the database' do
    ao  = FactoryBot.create(:action_officer)
    alm = FactoryBot.create(:actionlist_member)
    dd  = FactoryBot.create(:deputy_director)
    mc  = FactoryBot.create(:minister_contact)
    po  = FactoryBot.create(:press_officer)
    u   = FactoryBot.create(:user)

    RakeTaskHelpers::DBSanitizer.new.run!

    expect(ao.reload.email).to eq "pqsupport+ao#{ao.id}@digital.justice.gov.uk"
    expect(alm.reload.email).to eq "pqsupport+alm#{alm.id}@digital.justice.gov.uk"
    expect(dd.reload.email).to eq "pqsupport+dd#{dd.id}@digital.justice.gov.uk"
    expect(mc.reload.email).to eq "pqsupport+mc#{mc.id}@digital.justice.gov.uk"
    expect(po.reload.email).to eq "pqsupport+po#{po.id}@digital.justice.gov.uk"
    expect(u.reload.email).to eq "pqsupport+u#{u.id}@digital.justice.gov.uk"
    expect(wlm.reload.email).to eq "pqsupport+wlm#{wlm.id}@digital.justice.gov.uk"
    expect(ao.reload.group_email).to eq "pqsupport+gm#{ao.id}@digital.justice.gov.uk"
  end
end
