namespace :db do
  namespace :seed do
    desc 'Create user using factories'
    task user: :environment do
      user = FactoryGirl.build(:user)
      puts "Creating user #{user.email}, password '#{user.password}'"
      begin
        user.save!
        puts 'User created.'
      rescue
        puts 'User already exists. Cannot create.'
      end
    end

    desc 'Create questions in all states'
    task questions: :environment do
      5.times do
        QuestionStateMachine::STATES.each do |state|
          FactoryGirl.create("question_#{state}")
        end
        print '.'
      end
      puts "\rQuestions created."
    end
  end
end
