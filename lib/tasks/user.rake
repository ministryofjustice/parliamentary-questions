namespace :user do

  desc 'Creates an user with given name, email and password.'
  task :create, [:email, :password, :name] => :environment do |t, args|
    args.with_defaults(email: 'admin@admin.com', password: '123456789', name: 'User name')
    email, password, name = args[:email], args[:password],  args[:name]

    puts "Creating user with name: #{name} and email: #{email} with password: #{password}"
    User.create(email: email, password: password, name: name, role: User::ROLE_PQ_USER)
    puts 'User created!'
  end
end
