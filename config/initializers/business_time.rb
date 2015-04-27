require_relative 'business_time_helpers'
#    
# Configure BusinessTime options
#
# Define work day start/end times
BusinessTime::Config.beginning_of_workday = '8:00 am'
BusinessTime::Config.end_of_workday       = '6:00 pm'

# Define UK public holidays
BusinessTime::Config.holidays = BusinessTimeHelpers.load_holidays  
