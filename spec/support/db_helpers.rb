module DBHelpers
  module_function
  USER_PASSWORD = '123456789'

  FIXTURES = [
    :users,
    :ministers,
    :directorates,
    :divisions,
    :deputy_directors,
    :press_desks,
    :action_officers,
    :ogds,
    :pqs
  ]

  def load_spec_fixtures
  end

  def load_feature_fixtures
    load_fixtures(:ministers,
                  :directorates,
                  :divisions,
                  :deputy_directors,
                  :press_desks,
                  :action_officers,
                  :ogds)
  end

  def load_fixtures(*fixtures)
    FIXTURES.each do |m|
      method(m).call if fixtures.include?(m)
    end
  end

  def users
    [
     ['pq@pq.com', 'pq-user', User::ROLE_PQ_USER],
     ['fin@fin.com', 'finance-user', User::ROLE_FINANCE]
    ].map do |email, name, role|
      u = User.find_or_create_by(email: email, name: name, roles: role)
      if u.new_record?
        u.update(password: USER_PASSWORD, password_confirmation: USER_PASSWORD)
      end
      u
    end
  end

  def pqs(n=4)
    (1..n).map do |n|
      Pq.find_or_create_by(
        uin: "uin-#{n}",
        house_id: 1,
        raising_member_id: 1,
        tabled_date: Date.today,
        response_due: Date.tomorrow,
        question: "test question #{n}",
        state: PQState::UNASSIGNED
      )
    end
  end

  def ministers
    [
      {name: 'Chris Grayling', title: 'Secretary of State and Lord High Chancellor of Great Britain'},
      {name: 'Damian Green (MP)', title: 'Minister of State'},
      {name: 'Jeremy Wright (MP)', title: 'Parliamentary Under-Secretary of State; Minister for Prisons and Rehabilitation'},
      {name: 'Shailesh Vara (MP)', title: 'Parliamentary Under-Secretary of State'},
      {name: 'Simon Hughes (MP)',  title: 'Minister of State for Justice & Civil Liberties'},
      {name: 'Lord Faulks QC',  title: 'Lord Faulks QC, Minister of State'}
    ].map { |h| Minister.find_or_create_by(h) }
  end

  def directorates
    [
      {name: 'Finance Assurance and Commercial'},
      {name: 'Criminal Justice'},
      {name: 'Law and Access to Justice'},
      {name: 'NOMS'},
      {name: 'HMCTS'},
      {name: 'LAA and Corporate Services'},
    ].map { |h| Directorate.find_or_create_by(h) }
  end

  def divisions
    [
      {directorate:  directorates[0], name: 'Corporate Finance'},
      {directorate:  directorates[0], name: 'Analytical Services'},
      {directorate:  directorates[0], name: 'Procurement'},
      {directorate:  directorates[0], name: 'Change due diligence'},
      {directorate:  directorates[1], name: 'Sentencing and Rehabilitation Policy'},
      {directorate:  directorates[1], name: 'Justice Reform'},
      {directorate:  directorates[1], name: 'Transforming Rehabilitation'},
      {directorate:  directorates[1], name: 'MoJ Strategy'},
      {directorate:  directorates[2], name: 'Law, Rights, International'},
      {directorate:  directorates[2], name: 'Access to Justice'},
      {directorate:  directorates[2], name: 'Judicial Reward and Pensions reform'},
      {directorate:  directorates[2], name: 'Communications and Information'},
      {directorate:  directorates[3], name: 'HR'},
      {directorate:  directorates[3], name: 'Public Sector Prisons'},
      {directorate:  directorates[4], name: 'Civil, Family and Tribunals'},
      {directorate:  directorates[4], name: 'Crime'},
      {directorate:  directorates[4], name: 'IT'},
      {directorate:  directorates[5], name: 'Shared Services'},
      {directorate:  directorates[5], name: 'MoJ Technology'}
    ].map { |h| Division.find_or_create_by(h) }
  end

  def deputy_directors
    [
      {division: divisions[0], email: 'dd1@pq.com', name: 'deputy director 1'},
      {division: divisions[0], email: 'dd2@pq.com', name: 'deputy director 2'},
    ].map { |h| DeputyDirector.find_or_create_by(h) }
  end

  def press_desks
    [
      {name: 'Finance press desk'},
      {name: 'Prisons press desk'}
    ].map { |h| PressDesk.find_or_create_by(h) }
  end

  def press_offices
    [
      {name: 'press officer 1', email: 'one@press.office.com', press_desk: press_desks[0] },
      {name: 'press officer 2', email: 'two@press.office.com', press_desk: press_desks[1] },
    ].map { |h| PressOffice.find_or_create_by(h) }
  end

  def action_officers
    [
      {deputy_director: deputy_directors[0], name: 'action officer 1', email: 'ao1@pq.com', press_desk: press_desks[0]},
      {deputy_director: deputy_directors[1], name: 'action officer 2', email: 'ao2@pq.com', press_desk: press_desks[1]},
      {deputy_director: deputy_directors[1], name: 'action officer 3', email: 'ao3@pq.com', press_desk: press_desks[1]},
    ].map { |h| ActionOfficer.find_or_create_by(h) }
  end

  def ogds
    [
      {name:'Ministry of Defence', acronym:'MOD'}
    ].map { |h| Ogd.find_or_create_by(h) }
  end
end
