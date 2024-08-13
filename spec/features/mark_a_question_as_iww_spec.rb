require "feature_helper"

describe 'Creating an "I Will Write" question', :js do
  let(:dummy_ao) { ActionOfficer.find_by(email: "ao1@pq.com") }
  let(:dummy_uin) { PQA::QuestionLoader.new.load_and_import(1).first.uin }
  let(:dummy_iww_uin) { "#{dummy_uin}-IWW" }
  let(:dummy_minister) { Minister.first }

  before do
    DbHelpers.load_fixtures(:ministers, :action_officers)
    create_pq_session
  end

  it "Parli-branch marks a question as 'I will write'" do
    commission_question(dummy_uin, [dummy_ao], dummy_minister)
    accept_assignment(Pq.find_by(uin: dummy_uin), dummy_ao)
    in_pq_detail(dummy_uin, "PQ draft") { check "I will write" }

    expect(page).to have_title("PQ #{dummy_uin}")
    expect(page).to have_text("I will write")
  end
end
