require "rails_helper"
require Rails.root.join("lib/rake_task_helpers/db_sanitizer.rb").to_s

describe RakeTaskHelpers::DbSanitizer do
  it "sanitizes email in the selected tables of the database" do
    ao  = FactoryBot.create(:action_officer)
    dd  = FactoryBot.create(:deputy_director)
    mc  = FactoryBot.create(:minister_contact)
    po  = FactoryBot.create(:press_officer)
    u   = FactoryBot.create(:user)

    described_class.new.run!

    expect(ao.reload.email).to eq "pqsupport+ao#{ao.id}@digital.justice.gov.uk"
    expect(dd.reload.email).to eq "pqsupport+dd#{dd.id}@digital.justice.gov.uk"
    expect(mc.reload.email).to eq "pqsupport+mc#{mc.id}@digital.justice.gov.uk"
    expect(po.reload.email).to eq "pqsupport+po#{po.id}@digital.justice.gov.uk"
    expect(u.reload.email).to eq "pqsupport+u#{u.id}@digital.justice.gov.uk"
    expect(ao.reload.group_email).to eq "pqsupport+gm#{ao.id}@digital.justice.gov.uk"
  end
end
