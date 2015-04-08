namespace :pqa do
  desc "Perform nightly import"
  task :nightly_import, [] => :environment do
    ImportWorker.new.perform
  end


  desc "Import individual questions identified by UIN (rake pqa:import_uins['uin-1 uin-2 uin-3'])"
  task :import_uins, [:uins] => :environment do |_, args|
    uins = args[:uins].split
    importer = PQA::Import.new
    uins.each do |uin|
      begin
        report = importer.run_for_question(uin)
      rescue HTTPClient::FailureResponse => err 
        puts "UIN '#{uin}': #{err.message}"
      else
        puts analyse_report(uin, report)
      end
    end
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
    desc 'start a mock api service and load with n questions' 
    task :api_start, [:n_records] => :environment do |_, args|
      n_records = args[:n_records] || 3
      n_records = n_records.to_i if n_records.is_a?(String)
      require_relative '../pqa.rb'
      runner = PQA::MockApiServerRunner.new
      runner.start
      puts "Mock API server started on http://#{PQA::MockApiServerRunner::HOST}:#{PQA::MockApiServerRunner::PORT}"
      loader = PQA::QuestionLoader.new
      loader.load_and_import(n_records, true)
      puts "Mock API loaded with #{n_records} questions"
    end


    desc 'stops the mock api server if running' 
    task :api_stop => :environment do
      pid_filepath = "/tmp/mock_api_server.pid"
      if File.exists?(pid_filepath)
        pid  = File.read(pid_filepath)
        puts "pid file for process #{pid} found - attempting to kill"
        result = Process.kill("INT", pid.to_i)
        case result
        when 1
          puts "Process killed"
        else
          puts "Unable to kill process - try manually"
        end
      else
        puts "No pid file found for mock-api server - nothing to kill."
      end
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


  def analyse_report(uin, report)
    if report[:created] == 1
      "UIN '#{uin}': Created"
    elsif report[:updated] == 1
      "UIN '#{uin}': Updated"
    else
      "UIN '#{uin}': Error"
    end
  end
end
