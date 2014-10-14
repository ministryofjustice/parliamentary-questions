Given(/^I there is a (.*) question$/) do |factory_type|
  factory_name = "#{factory_type.downcase.gsub(' ', '_')}_pq".to_sym
  @pq = FactoryGirl.create(factory_name)
end

When(/^I open the dashboard with that question$/) do
  @page = UI::Pages::Dashboard.new
end

When(/^I assign ministers, action officers and choose the dates$/) do
  @minister = FactoryGirl.create(:minister)
  @action_officer = FactoryGirl.create(:action_officer)

  # Fixme this does not semantically belong here, so it should be moved
  @page.load

  f = @page.commission_form
  f.minister.select(@minister.name)
  f.policy_minister.select(@minister.name)
  f.action_officers.select(@action_officer.name)
  f.date_for_answer.set(Time.now + 12.days)
  f.internal_deadline.set(Time.now + 10.days)
  f.commission_button.click
end

Then(/^the question should be commissioned$/) do
  expect(@pq).to be_commissioned
end