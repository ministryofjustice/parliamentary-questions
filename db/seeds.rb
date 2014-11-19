# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'Clear tables'
ActiveRecord::Base.connection.execute("TRUNCATE TABLE progresses RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE ministers RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE directorates RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE divisions RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE deputy_directors RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE action_officers RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE press_desks RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE press_officers RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE ogds RESTART IDENTITY;")

puts '-populate'
progresses = Progress.create([
  {name: Progress.UNASSIGNED},
  {name: Progress.NO_RESPONSE},
  {name: Progress.ACCEPTED},
  {name: Progress.REJECTED},
  {name: Progress.DRAFT_PENDING},
  {name: Progress.WITH_POD},
  {name: Progress.POD_QUERY},
  {name: Progress.POD_CLEARED},
  {name: Progress.WITH_MINISTER},
  {name: Progress.MINISTERIAL_QUERY},
  {name: Progress.MINISTER_CLEARED},
  {name: Progress.ANSWERED},
  {name: Progress.TRANSFERRED_OUT}])

ministers = Minister.create!([
	{name: 'Chris Grayling', title: 'Secretary of State and Lord High Chancellor of Great Britain'},
	{name: 'Damian Green (MP)', title: 'Minister of State'},
	{name: 'Jeremy Wright (MP)', title: 'Parliamentary Under-Secretary of State; Minister for Prisons and Rehabilitation'},
	{name: 'Shailesh Vara (MP)', title: 'Parliamentary Under-Secretary of State'},
	{name: 'Simon Hughes (MP)',  title: 'Minister of State for Justice & Civil Liberties'},
	{name: 'Lord Faulks QC',  title: 'Lord Faulks QC, Minister of State'}])

directorates = Directorate.create!([
	{name: 'Finance Assurance and Commercial'},
	{name: 'Criminal Justice'},
	{name: 'Law and Access to Justice'},
	{name: 'NOMS'},
	{name: 'HMCTS'},
	{name: 'LAA and Corporate Services'},
	])

divisions = Division.create!([
	{directorate_id:  1, name: 'Corporate Finance'},
	{directorate_id:  1, name: 'Analytical Services'},
	{directorate_id:  1, name: 'Procurement'},
	{directorate_id:  1, name: 'Change due diligence'},
	{directorate_id:  2, name: 'Sentencing and Rehabilitation Policy'},
	{directorate_id:  2, name: 'Justice Reform'},
	{directorate_id:  2, name: 'Transforming Rehabilitation'},
	{directorate_id:  2, name: 'MoJ Strategy'},
	{directorate_id:  3, name: 'Law, Rights, International'},
	{directorate_id:  3, name: 'Access to Justice'},
	{directorate_id:  3, name: 'Judicial Reward and Pensions reform'},
	{directorate_id:  3, name: 'Communications and Information'},
	{directorate_id:  4, name: 'HR'},
	{directorate_id:  4, name: 'Public Sector Prisons'},
	{directorate_id:  5, name: 'Civil, Family and Tribunals'},
	{directorate_id:  5, name: 'Crime'},
	{directorate_id:  5, name: 'IT'},
	{directorate_id:  6, name: 'Shared Services'},
	{directorate_id:  6, name: 'MoJ Technology'}
	])

deputy_directors = DeputyDirector.create!([
	{division_id: 1, name: 'Craig Watkins'},
	{division_id: 2, name: 'Rebecca Endean'},
	{division_id: 3, name: 'Procurement'},
	{division_id: 4, name: 'Jonathon Sedgwick'},
	{division_id: 5, name: 'Helen Judge'},
	{division_id: 6, name: 'Paul Kett'},
	{division_id: 7, name: 'Ian Poree'},
	{division_id: 8, name: 'Darren Tierney'},
	{division_id: 9, name: 'Mark Sweeney'},
	{division_id: 10, name: 'Vacant'},
	{division_id: 11, name: 'Pat Lloyd'},
	{division_id: 12, name: 'Pam Teare'},
	{division_id: 13, name: 'Carol Carpenter'},
	{division_id: 14, name: 'Phil Copple'},
	{division_id: 15, name: 'Kevin Sadler'},
	{division_id: 16, name: 'Guy Tompkins'},
	{division_id: 17, name: 'Paul Shipley'},
	{division_id: 18, name: 'Gerry Smith'},
	{division_id: 19, name: 'Nick Ramsey'}
	])

PressDesk.create!([
    {name: 'Finance press desk'},
    {name: 'Prisons press desk'}
    ])
PressOfficer.create!([
    {name: 'press officer one', email: 'one@press.office.com', press_desk_id: 1 },
    {name: 'press officer two', email: 'two@press.office.com', press_desk_id: 1 },
    {name: 'press officer three', email: 'three@press.office.com', press_desk_id: 2 },
    {name: 'press officer four', email: 'four@press.office.com', press_desk_id: 2 },
    ])
action_officers = ActionOfficer.create!([
	{deputy_director_id: 17, name: 'Colin Bruce', email: 'colin.bruce@digital.justice.gov.uk', press_desk_id: 1},
	{deputy_director_id: 19, name: 'Daniel Penny', email: 'daniel.penny@digital.justice.gov.uk', press_desk_id: 1},
	{deputy_director_id: 6, name: 'David Hernandez', email: 'david.hernandez@digital.justice.gov.uk', press_desk_id: 1},
	{deputy_director_id: 7, name: 'Tehseen Udin', email: 'tehseen.udin@digital.justice.gov.uk', press_desk_id: 1},
	{deputy_director_id: 8, name: 'Tom Wynne-Morgan', email: 'tom.wynne-morgan@digital.justice.gov.uk', press_desk_id: 2},
	{deputy_director_id: 9, name: 'Tom Norman', email: 'tom.norman@digital.justice.gov.uk', press_desk_id: 2},
	{deputy_director_id: 10, name: 'Mary Henley', email: 'mary.henley@digital.justice.gov.uk', press_desk_id: 2}
	])

Ogd.create!([
    {name:'Ministry of Defence', acronym:'MOD'}
  ])

puts 'Done'
