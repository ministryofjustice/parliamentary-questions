namespace :demo do
  desc "setup demonstration questions"
  task setup: :environment do
    delete_existing_demo_questions
    seed_questions = populate_seeds
    (1..5).each do |i|
      create_question(seed_questions[i - 1])
    end
  end

  desc "set up staging database for training demo"
  task training_setup: :environment do
    if HostEnv.is_staging? || HostEnv.is_dev? || Rails.env.development?
      setup_users
      setup_training_action_officers
      setup_training_questions
    else
      raise "DANGER!  This task updates the database. May only be run in staging or dev environments"
    end
  end
end

def setup_users
  user = User.find_by(name: "Rahul Mehta")
  user.update!(email: "rahul.meta@justice.gsi.gov.uk")
end

def setup_training_action_officers
  [
    ["Marcus Tucker-Cooper", "Marcus.Tucker-Cooper@justice.gsi.gov.uk", 43],
    ["James Wood", "james.wood1@justice.gsi.gov.uk", 3],
    ["Jake Thirkell", "jake.thirkell@justice.gsi.gov.uk", 35],
  ].each do |ao_dets|
    name, email, division_id = ao_dets
    ao = ActionOfficer.where("name = ?", name).first
    ao.update!(email:)
    allocate_division_to_ao(ao, division_id)
  end
end

def allocate_division_to_ao(action_officer, division_id)
  division = Division.find(division_id)
  action_officer.update!(deputy_director_id: division.deputy_directors.active.first.id)
end

def setup_training_questions
  dupe_pqs = {
    "HL2983" => "HL8954",
    "220661" => "HL8957",
    "218894" => "899344",
    "218333" => "899325",
    "HL5762" => "HL8951",
    "226031" => "899322",
    "220161" => "899316",
    "228151" => "899310",
    "208826" => "899311",
  }
  dupe_pqs.each do |old_uin, new_uin|
    old_pq = Pq.uin(old_uin)
    duplicate_question(old_pq, new_uin)
  end
end

def duplicate_question(old_pq, new_uin)
  Pq.create!(
    house_id: old_pq.house_id,
    raising_member_id: old_pq.raising_member_id,
    tabled_date: 1.day.ago,
    question: old_pq.question,
    uin: new_uin,
    member_name: old_pq.member_name,
    member_constituency: old_pq.member_constituency,
    house_name: old_pq.house_name,
    date_for_answer: 2.days.from_now,
    registered_interest: old_pq.registered_interest,
    question_type: old_pq.question_type,
    transferred: old_pq.transferred,
    question_status: "Tabled",
    state: "unassigned",
    state_weight: 0,
  )
end

def delete_existing_demo_questions
  Pq.where("uin like 'uin-%'").map(&:destroy)
  Pq.where("uin like '8%'").map(&:destroy)
end

def populate_seeds
  seed_question_uins = %w[201828 208682 209418 209416 210144]
  seed_questions = []
  seed_question_uins.each { |uin| seed_questions << Pq.find_by(uin:) }
  seed_questions
end

def create_question(seed_question)
  uin = (seed_question.uin.to_i + 600_000).to_s

  Pq.create!(
    house_id: nil,
    raising_member_id: 2479,
    tabled_date: 1.day.ago,
    question: seed_question.question,
    uin:,
    member_name: seed_question.member_name,
    member_constituency: seed_question.member_constituency,
    house_name: "House of Commons",
    date_for_answer: 2.days.from_now,
    registered_interest: false,
    question_type: seed_question.question_type,
    transferred: false,
    question_status: "Tabled",
    state: "unassigned",
    state_weight: 0,
  )
end
