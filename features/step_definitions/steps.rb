Given(/^There is a (.*) question$/) do |factory_type|
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

When(/^the action officer (accepts|rejects) it$/) do |action|
  # Todo find better way of generating the token url
  path = "/assignment/#{@pq.uin.encode}"
  entity = "assignment:#{@pq.action_officers_pq.first.id}"
  token = TokenService.new.generate_token(path, entity, 1.day.from_now)

  @page = UI::Pages::Assignment.new
  @page.load(uin: @pq.uin, entity: entity, token: token)

  case action
    when 'accepts'
      @page.accept.set(true)
    when 'rejects'
      @page.reject.set(true)
      @page.reject_reason_option.select('I think it is for another person in my department')
      @page.reject_reason_text.set(Faker::Lorem.sentence(5))
  end

  @page.save.click
end

Then(/^the question should be (.*)$/) do |state|
  @pq.reload

  case state
    when 'commissioned'
      expect(@pq).to be_commissioned
    else
      expect(@pq).to be_is_in_progress(Progress.find_by(name: Progress.send(state.upcase)))
  end
end