desc 'run brakeman on the app and report any errors'
task :brakeman do 
  ROOT_DIR        = File.expand_path(File.basename(__FILE__) + '/../')
  RED             = "\033[0;31m"
  GREEN           = "\033[0;32m"
  NO_COLOR        = "\033[0m"
  SUCCESS_MESSAGE = "Brakeman detected no warnings"
  ERROR_MESSAGE   = "WARNING!!! Brakeman detected errors:  If these can be SAFELY ignored, run in interactive mode (-I) to add to config/brakeman.ignore\n" +
                    "View file brakeman_out.txt for details of errors."

  error_free = system('brakeman -4 -o brakeman_out.txt -z -i config/brakeman.ignore --table-width 250 > /dev/null  2>&1')
  # error_free = system('brakeman -4 -o brakeman_out.txt -z -i config/brakeman.ignore --table-width 250')
  if error_free
    puts "#{GREEN}#{SUCCESS_MESSAGE}#{NO_COLOR}"
  else
    puts "#{RED}#{ERROR_MESSAGE}#{NO_COLOR}"
  end
end