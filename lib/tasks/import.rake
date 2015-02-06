namespace :db do
  desc "Generate and import dummy data for development"
  task :import_dummy_data, [:n_records] => :environment do |_, args|
    n_records = args[:n_records] || 3

    runner    = PQA::MockApiServerRunner.new
    import    = PQA::Import.new
    loader    = PQA::QuestionLoader.new
    questions = (1..n_records.to_i).map do |n|
      PQA::QuestionBuilder.default("uin-#{n}")
    end

    begin
      runner.start
      loader.load(questions)
      report = import.run(Date.yesterday, Date.tomorrow)
      puts report.inspect
    ensure
      runner.stop
    end
  end
end
