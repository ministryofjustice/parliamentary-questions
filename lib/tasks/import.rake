namespace :pqa do
  desc "Perform nightly import"
  task :nightly_import, [] => :environment do
    ImportWorker.new.perform
  end

  desc "Generate and import dummy data for development"
  task :import_dummy_data, [:n_records] => :environment do |_, args|
    n_records = args[:n_records] || 3
    questions = (1..n_records.to_i).map do |n|
      PQA::QuestionBuilder.default("uin-#{n}")
    end

    import_from_mock_server(questions, Date.yesterday, Date.tomorrow)
  end

  desc "Import questions from XML file"
  task :import_from_xml, [:xml_path] => :environment do |_, args|
    fpath = args[:xml_path]
    raise ArgumentError, "Cannot find file #{fpath}" unless File.exists?(fpath)

    min_date  = Date.parse('1/1/2000')
    max_date  = Date.parse('1/1/2020')
    questions = PQA::XMLDecoder.decode_questions(File.read(fpath))

    import_from_mock_server(questions, min_date, max_date)
  end

  namespace :mock do
    desc 'start a mock api service and load with 50 questions' 
    task :api, [:n_records] => :environment do |_, args|
      n_records = args[:n_records] || 3
      require_relative '../pqa.rb'
      runner = PQA::MockApiServerRunner.new
      runner.start
      puts "Mock API server started on http://#{PQA::MockApiServerRunner::HOST}:#{PQA::MockApiServerRunner::PORT}"
      loader = PQA::QuestionLoader.new
      loader.load_and_import(n_records, true)
      puts "Mock API loaded with #{n_records} questions"
    end
  end


  private

  def import_from_mock_server(questions, date_from, date_to)
    runner    = PQA::MockApiServerRunner.new
    import    = PQA::Import.new
    loader    = PQA::QuestionLoader.new
    begin
      runner.start
      loader.load(questions)
      report = import.run(date_from, date_to)
      puts report.inspect
    ensure
      runner.stop
    end
  end
end
