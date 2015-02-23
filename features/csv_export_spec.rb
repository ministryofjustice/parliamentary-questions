=begin
  

Senario
As a PB user given that I click on the export to csv link 
Then I should see the Export to CSV view. 

When I select a date from and date to values and click the csv button.
Then the CSV file should download. 
And data should contain all questions where the table date is greater than 
or equal to the date form and the answer date is either null or less then or 
equal too the date to.
And data should not include questions that have been transferred out. 
=end
require 'feature_helper'

feature 'Transferring questions', js: true do
  include Features::PqHelpers

  before(:all) do
    DBHelpers.load_feature_fixtures

    @pq, _ =  PQA::QuestionLoader.new.load_and_import(2)
    set_seen_by_finance
  end

end