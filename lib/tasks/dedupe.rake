namespace :dedupe do


  task :check => :environment do
    require 'csv'
    DIVISIONS_FILE = '/Users/stephen/tmp/division_changes.csv'
    data = CSV.read(DIVISIONS_FILE)
    data.shift

    data.each do |row|
      pq_id, uin, ao_id, name, pq_div_id, pq_div_name, ao_div_id, ao_div_name, correct_division = row
      next if correct_division.nil?
      pq = Pq.uin(uin)
      puts "checking UIN #{uin}"
      expected_div_name = correct_division.strip.upcase == 'CURRENT' ? ao_div_name : pq_div_name
      if expected_div_name.strip != pq.original_division.name.strip
        puts ">>>>>> UIN #{uin}"
      end
    end


  end
  
  desc 'change original division on PQ to what it should be'
  task :div_change => :environment do
    fixer = PqDivisionFixer.new
    fixer.fix!
    fixer.report
  end


  desc 'removes duplicate action officers' 
  task :ao => :environment do
    dupes = {
      378 => 257,
      220 => 233,
      214 => 385,
      150 => 261,
      428 => 427,
      405 => 35,
      263 => 59,
      352 => 85,
      30  => 104,
      97  => 25,
      225 => 327,
      231 => 126,
      232 => 126,
      202 => 371,
      299 => 412,
      93  => 223,
      280 => 197,
      138 => 57
    }
    fixer = DupeActionOfficerFixer.new(dupes)
    fixer.dedupe!
    fixer.report

  end



  desc 'removes duplicate deputy directors' 
  task :dd => :environment do
    dupes = {
      214 => 213,
      73 => 215,
      217 => 215,
      216 => 215,
      219 => 215,
      218 => 215,
      136 => 21,
      54 => 21,
      108 => 43,
      26 => 1,
      51 => 78,
      220 => 215,
      222 => 215,
      221 => 215,
      223 => 215
    }


    fixer  = DupeDeputyDirectorFixer.new(dupes)
    fixer.dedupe!
    fixer.report
  end

end