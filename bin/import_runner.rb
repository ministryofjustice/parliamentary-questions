require 'pp'

date_from = Date.parse('1/6/2014')
import = PQA::Import.new
report = import.run(date_from, Date.today)

pp report
