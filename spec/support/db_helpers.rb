module DBHelpers
  module_function

  def load_spec_seeds
    Progress.create!([
      {name: Progress.UNASSIGNED},
      {name: Progress.NO_RESPONSE},
      {name: Progress.REJECTED},
      {name: Progress.DRAFT_PENDING},
      {name: Progress.WITH_POD},
      {name: Progress.POD_QUERY},
      {name: Progress.POD_CLEARED},
      {name: Progress.WITH_MINISTER},
      {name: Progress.MINISTERIAL_QUERY},
      {name: Progress.MINISTER_CLEARED},
      {name: Progress.ANSWERED},
      {name: Progress.TRANSFERRED_OUT}
    ])
  end

  def load_feature_seeds
    load_spec_seeds
    Minister.create!([
      {name: 'Chris Grayling', title: 'Secretary of State and Lord High Chancellor of Great Britain'},
      {name: 'Damian Green (MP)', title: 'Minister of State'},
      {name: 'Jeremy Wright (MP)', title: 'Parliamentary Under-Secretary of State; Minister for Prisons and Rehabilitation'},
      {name: 'Shailesh Vara (MP)', title: 'Parliamentary Under-Secretary of State'},
      {name: 'Simon Hughes (MP)',  title: 'Minister of State for Justice & Civil Liberties'},
      {name: 'Lord Faulks QC',  title: 'Lord Faulks QC, Minister of State'}
    ])

    directorates = Directorate.create!([
      {name: 'Finance Assurance and Commercial'},
      {name: 'Criminal Justice'},
      {name: 'Law and Access to Justice'},
      {name: 'NOMS'},
      {name: 'HMCTS'},
      {name: 'LAA and Corporate Services'},
    ])

    divisions = Division.create!([
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
    ])

    deputy_directors = DeputyDirector.create!([
      {division: divisions[0], name: 'deputy director 1'},
      {division: divisions[0], name: 'deputy director 2'},
    ])

    press_desks = PressDesk.create!([
      {name: 'Finance press desk'},
      {name: 'Prisons press desk'}
    ])

    PressOfficer.create!([
      {name: 'press officer 1', email: 'one@press.office.com', press_desk: press_desks[0] },
      {name: 'press officer 2', email: 'two@press.office.com', press_desk: press_desks[1] },
    ])

     ActionOfficer.create!([
      {deputy_director: deputy_directors[0], name: 'action officer 1', email: 'ao1@pq.com', press_desk: press_desks[0]},
      {deputy_director: deputy_directors[1], name: 'action officer 2', email: 'ao2@pq.com', press_desk: press_desks[1]},
    ])

    Ogd.create!([
        {name:'Ministry of Defence', acronym:'MOD'}
    ])
  end
end
