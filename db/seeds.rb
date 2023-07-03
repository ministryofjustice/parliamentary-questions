# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts "Clear tables"
ActiveRecord::Base.connection.execute("TRUNCATE TABLE progresses RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE ministers RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE directorates RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE divisions RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE deputy_directors RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE action_officers RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE press_desks RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE press_officers RESTART IDENTITY;")
ActiveRecord::Base.connection.execute("TRUNCATE TABLE ogds RESTART IDENTITY;")

puts "-populate"
progresses = Progress.create([
  { name: Progress.UNASSIGNED },
  { name: Progress.NO_RESPONSE },
  { name: Progress.REJECTED },
  { name: Progress.DRAFT_PENDING },
  { name: Progress.WITH_POD },
  { name: Progress.POD_QUERY },
  { name: Progress.POD_CLEARED },
  { name: Progress.WITH_MINISTER },
  { name: Progress.MINISTERIAL_QUERY },
  { name: Progress.MINISTER_CLEARED },
  { name: Progress.ANSWERED },
  { name: Progress.TRANSFERRED_OUT },
])

ministers = Minister.create!([
  { name: "Dimple Machado", title: "Secretary of State and Lord High Chancellor of Great Britain" },
  { name: "Herma Goble (MP)", title: "Minister of State" },
  { name: "Teddy Pool (MP)", title: "Parliamentary Under-Secretary of State; Minister for Prisons and Rehabilitation" },
  { name: "Ligia Dowdy (MP)", title: "Parliamentary Under-Secretary of State" },
  { name: "Son Putnam (MP)",  title: "Minister of State for Justice & Civil Liberties" },
  { name: "Belkis Naranjo QC", title: "Minister of State" },
])

directorates = Directorate.create!([
  { name: "Finance Assurance and Commercial" },
  { name: "Criminal Justice" },
  { name: "Law and Access to Justice" },
  { name: "NOMS" },
  { name: "HMCTS" },
  { name: "LAA and Corporate Services" },
])

divisions = Division.create!([
  { directorate_id: 1, name: "Corporate Finance" },
  { directorate_id:  1, name: "Analytical Services" },
  { directorate_id:  1, name: "Procurement" },
  { directorate_id:  1, name: "Change due diligence" },
  { directorate_id:  2, name: "Sentencing and Rehabilitation Policy" },
  { directorate_id:  2, name: "Justice Reform" },
  { directorate_id:  2, name: "Transforming Rehabilitation" },
  { directorate_id:  2, name: "MoJ Strategy" },
  { directorate_id:  3, name: "Law, Rights, International" },
  { directorate_id:  3, name: "Access to Justice" },
  { directorate_id:  3, name: "Judicial Reward and Pensions reform" },
  { directorate_id:  3, name: "Communications and Information" },
  { directorate_id:  4, name: "HR" },
  { directorate_id:  4, name: "Public Sector Prisons" },
  { directorate_id:  5, name: "Civil, Family and Tribunals" },
  { directorate_id:  5, name: "Crime" },
  { directorate_id:  5, name: "IT" },
  { directorate_id:  6, name: "Shared Services" },
  { directorate_id:  6, name: "MoJ Technology" },
])

deputy_directors = DeputyDirector.create!([
  { division_id: 1, email: "dd1@email.com", name: "Dollie Christenson" },
  { division_id: 2, email: "dd2@email.com", name: "Logan Lavoie" },
  { division_id: 3, email: "dd3@email.com", name: "Aja Song" },
  { division_id: 4, email: "dd4@email.com", name: "Rory Otis" },
  { division_id: 5, email: "dd5@email.com", name: "Myrtice Mattox" },
  { division_id: 6, email: "dd6@email.com", name: "Ozella Yoo" },
  { division_id: 7, email: "dd7@email.com", name: "Francoise Mcalister" },
  { division_id: 8, email: "dd8@email.com", name: "Romeo Pipkin" },
  { division_id: 9, email: "dd9@email.com", name: "Kyra Orr" },
  { division_id: 10, email: "dd10@email.com",  name: "Kaycee Bonner" },
  { division_id: 11, email: "dd11@email.com",  name: "Issac Otto" },
  { division_id: 12, email: "dd12@email.com",  name: "Nohemi Mullen" },
  { division_id: 13, email: "dd13@email.com",  name: "Bree Fries" },
  { division_id: 14, email: "dd14@email.com",  name: "Ashton Valerio" },
  { division_id: 15, email: "dd15@email.com",  name: "Jesus Staton" },
  { division_id: 16, email: "dd16@email.com",  name: "Jere Huggins" },
  { division_id: 17, email: "dd17@email.com",  name: "Buddy Kent" },
  { division_id: 18, email: "dd18@email.com",  name: "Benito Canales" },
  { division_id: 19, email: "dd19@email.com",  name: "Hyman Quinones" },
])

PressDesk.create!([
  { name: "Finance press desk" },
  { name: "Prisons press desk" },
])

PressOfficer.create!([
  { name: "Vertie Engel ", email: "po-one@press.office.com", press_desk_id: 1 },
  { name: "Bok Mcgehee", email: "po-two@press.office.com", press_desk_id: 1 },
  { name: "Lawanna Whitcomb", email: "po-three@press.office.com", press_desk_id: 2 },
  { name: "Delmer Gaskin", email: "po-four@press.office.com", press_desk_id: 2 },
])

action_officers = ActionOfficer.create!(
  [
    { deputy_director_id: 17, name: "Nick Preddy", email: "nick.preddy@digital.justice.gov.uk", press_desk_id: 1 },
    { deputy_director_id: 19, name: "Daniel Penny", email: "daniel.penny@digital.justice.gov.uk", press_desk_id: 1 },
    { deputy_director_id: 6, name: "Opal Moody", email: "ao-six@email.com", press_desk_id: 1 },
    { deputy_director_id: 7, name: "Doug Sherman", email: "ao-seven@email.com", press_desk_id: 1 },
    { deputy_director_id: 8, name: "Loretta Floyd", email: "ao-eight@email.com", press_desk_id: 2 },
    { deputy_director_id: 9, name: "Clyde Medina", email: "ao-nine@email.com", press_desk_id: 2 },
    { deputy_director_id: 10, name: "Marsha Huff ", email: "ao-ten@email.com", press_desk_id: 2 },
  ],
)

Ogd.create!([
  { name: "Ministry of Defence", acronym: "MOD" },
])

puts "Done"
