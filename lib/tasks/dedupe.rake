namespace :dedupe do
  
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