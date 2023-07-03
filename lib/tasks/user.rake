namespace :user do
  desc "Creates an user with given name, email and password."
  task :create, %i[email password name] => :environment do |_t, args|
    raise "This task should NOT be run in a production environment" if HostEnv.is_live?

    args.with_defaults(email: "admin@admin.com", password: "123456789", name: "User name")
    email = args[:email]
    password = args[:password]
    name = args[:name]

    puts "Creating user with name: #{name} and email: #{email} with password: #{password}"
    User.create!(email:, password:, name:, roles: User::ROLE_PQ_USER)
    puts "User created!"
  end
end
