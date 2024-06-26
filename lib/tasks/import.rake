# RuboCop::RakeTask.new do |task|
#   task.requires << "rubocop-rails"
# end

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
      report = importer.run_for_question(uin)
    rescue HTTPClient::FailureResponse => e
      puts "UIN '#{uin}': #{e.message}"
    else
      if report[:created] == 1
        puts "UIN '#{uin}': Created"
      elsif report[:updated] == 1
        puts "UIN '#{uin}': Updated"
      else
        puts "UIN '#{uin}': Error"
      end
    end
  end

  desc "Generate and import 'n' dummy questions by name"
  # Console syntax: bundle exec rake pqa:import_dummy_data['Question',5]
  task :import_dummy_data, %i[uin_prefix n_records] => :environment do |_, args|
    args.with_defaults(uin_prefix: "uin", n_records: 1)
    n_records = args[:n_records]
    uin_prefix = args[:uin_prefix]

    questions =
      (1..n_records.to_i).map do |n|
        PQA::QuestionBuilder.default(uin_prefix.to_s + "-#{n}")
      end

    runner = PQA::MockApiServerRunner.new
    import = PQA::Import.new
    loader = PQA::QuestionLoader.new
    begin
      runner.start
      loader.load(questions)
      report = import.run(Date.yesterday, Date.tomorrow)
      puts report.inspect
    ensure
      runner.stop
    end
  end

  desc "Import questions from XML file"
  # Console syntax: bundle exec rake pqa:import_from_xml['questions.xml']
  task :import_from_xml, [:xml_path] => :environment do |_, args|
    fpath = args[:xml_path]
    raise ArgumentError, "Cannot find file #{fpath}" unless File.exist?(fpath)

    min_date  = Date.parse("1/1/2000")
    max_date  = Date.parse("1/1/2020")
    questions = PQA::XmlDecoder.decode_questions(File.read(fpath))

    runner = PQA::MockApiServerRunner.new
    import = PQA::Import.new
    loader = PQA::QuestionLoader.new
    begin
      runner.start
      loader.load(questions)
      report = import.run(min_date, max_date)
      puts report.inspect
    ensure
      runner.stop
    end
  end

  namespace :mock do
    desc "start a mock api service and load with n questions"
    task :api_start, [:n_records] => :environment do |_, args|
      n_records = args[:n_records] || 3
      n_records = n_records.to_i if n_records.is_a?(String)
      require_relative "../pqa"
      runner = PQA::MockApiServerRunner.new
      runner.start
      puts "Mock API server started on http://#{PQA::MockApiServerRunner::HOST}:#{PQA::MockApiServerRunner::PORT}"
      loader = PQA::QuestionLoader.new
      loader.load_and_import(n_records, true)
      puts "Mock API loaded with #{n_records} questions"
    end

    desc "stops the mock api server if running"
    task api_stop: :environment do
      pid_filepath = "/tmp/mock_api_server.pid"
      if File.exist?(pid_filepath)
        pid = File.read(pid_filepath)
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
end
