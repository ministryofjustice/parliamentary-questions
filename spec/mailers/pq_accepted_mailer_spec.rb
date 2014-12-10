require 'spec_helper'

describe 'PQAcceptedMailer' do
  let(:contact1) { create(:minister_contact, email: 'test1@tesk.uk')}
  let(:contact2) { create(:minister_contact, email: 'test2@tesk.uk')}
  let(:ao) { create(:action_officer, name: 'ao name 1', email: 'ao@ao.gov') }
  let(:minister_1) { create(:minister, name: 'Mr Name1 for Test') }
  let(:minister_2) { create(:minister, name: 'Mr Name2 for Test') }
  let(:minister_simon) { create(:minister, name: 'Simon Hughes (MP)') }
  let(:dd) {create(:deputy_director, name: 'Deputy Director', email:'dep@dep.gov')}

  before(:each) do
    ActionMailer::Base.deliveries = []
    minister_1.minister_contacts << contact1
    minister_2.minister_contacts << contact2
  end

  describe '#deliver' do
    it 'should set question and the email' do
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id)
      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first
      expect(mail.html_part.body).to include pq.text

      expect(mail.text_part.body).to include pq.text
      expect(mail.to).to include ao.email
    end

    it 'should set the right cc with minister ' do
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, internal_deadline: '01/01/2014 10:30')
      expectedCC = 'test1@tesk.uk'

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include expectedCC
      expect(mail.html_part.body).to include CGI::escape(expectedCC)
    end

    it 'should set the right cc with minister the right people if the minister is Simon Hughes' do
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_simon.id, policy_minister_id: minister_2.id)
      expectedCC = 'Christopher.Beal@justice.gsi.gov.uk;Nicola.Calderhead@justice.gsi.gov.uk;thomas.murphy@JUSTICE.gsi.gov.uk'

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include expectedCC
      expect(mail.html_part.body).to include CGI::escape(expectedCC)
    end

    it 'should add the people from the Actionlist to the CC on the draft email link' do
      create(:actionlist_member, name: 'A1', email: 'a1@a1.com', deleted: false)
      create(:actionlist_member, name: 'A2', email: 'a2@a2.com', deleted: false)
      create(:actionlist_member, name: 'A3', email: 'a3@a3.com', deleted: true)

      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id)
      expectedCC = 'test1@tesk.uk;test2@tesk.uk;a1@a1.com;a2@a2.com'

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include expectedCC
      expect(mail.html_part.body).to include CGI::escape(expectedCC)
    end

    it 'should contain the name of the minister' do
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id)

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include minister_1.name
      expect(mail.html_part.body).to include minister_1.name
    end

    it 'should contain the asking minister ' do
      member_name =  'Jeremy Snodgrass'
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, member_name: member_name, house_name: 'HoL')

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include member_name
      expect(mail.html_part.body).to include member_name
    end

    it 'should contain the house ' do
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, member_name: 'Jeremy Snodgrass', house_name: 'HoL')

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include 'HoL'
      expect(mail.html_part.body).to include 'HoL'
    end

    it 'should add the Finance email to the CC list on the draft email link if Finance has registered an interest in the question' do

      create(:actionlist_member, name: 'A1', email: 'a1@a1.com', deleted: false)

      my_finance_email =  'financepq@wibble.com'
      create(:user, name:'Finance Guy1', roles:'FINANCE', deleted: false, email:my_finance_email, password:'bloibbloibbloibbloibbloib')
      create(:user, name:'Finance Guy2', roles:'FINANCE', deleted: true, email:'financePQ2@wibble.com', password:'bloib2bloib2bloib2bloib2')


      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id, finance_interest: true)

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include my_finance_email
      expect(mail.html_part.body).to include CGI::escape(my_finance_email)
    end

    it 'should not add the Finance email to the CC list on the draft email link if Finance has not registered an interest in the question' do
      create(:actionlist_member, name: 'A1', email: 'a1@a1.com', deleted: false)
      create(:actionlist_member, name: 'A2', email: 'a2@a2.com', deleted: false)
      create(:actionlist_member, name: 'A3', email: 'a3@a3.com', deleted: true)
      my_finance_email =  'financepq@wibble.com'
      create(:user, name:'Finance Guy1', roles:'FINANCE', deleted: false, email:my_finance_email, password:'bloibbloibbloibbloibbloib')

      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id, finance_interest: false)

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to_not include my_finance_email
      expect(mail.html_part.body).to_not include CGI::escape(my_finance_email)
    end

    it 'should not add the Finance email to the CC list on the draft email link if Finance has registered an interest in the question but is inactive' do

      create(:actionlist_member, name: 'A1', email: 'a1@a1.com', deleted: false)
      create(:actionlist_member, name: 'A2', email: 'a2@a2.com', deleted: false)
      create(:actionlist_member, name: 'A3', email: 'a3@a3.com', deleted: true)
      my_finance_email =  'financepq@wibble.com'
      create(:user, name:'Finance Guy1', roles:'FINANCE', deleted: true, email:my_finance_email, password:'bloibbloibbloibbloibbloib')

      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id, finance_interest: true)

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to_not include my_finance_email
      expect(mail.html_part.body).to_not include CGI::escape(my_finance_email)
    end

    it 'should show the date for answer if set' do
      pq = create(:question, uin: 'HL789', date_for_answer: Date.new(2014,9,4), text: 'test question?', minister_id: minister_1.id, member_name: 'Jeremy Snodgrass', house_name: 'HoL')

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include '04/09/2014'
      expect(mail.html_part.body).to include '04/09/2014'
    end

    it 'should not show the date for answer block if not set' do
      pq = create(:question, uin: 'HL789', date_for_answer: nil, text: 'test question?', minister_id: minister_1.id, member_name: 'Jeremy Snodgrass', house_name: 'HoL')

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to_not include 'Due back to Parliament by '
      expect(mail.html_part.body).to_not include 'Due back to Parliament by '
    end

    it 'should add the deputy director of the AO to the CC on the draft email link' do
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id)
      expectedCC = 'dep@dep.gov'
      ao.deputy_director = dd

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to include expectedCC
      expect(mail.html_part.body).to include CGI::escape(expectedCC)
    end

    it 'should not add the deputy director of the AO to the CC on the draft email link if the ao has no dd ' do
      pq = create(:question, uin: 'HL789', text: 'test question?', minister_id: minister_1.id, policy_minister_id: minister_2.id)
      expectedCC = 'dep@dep.gov'

      PqMailer.acceptance_email(pq, ao).deliver

      mail = ActionMailer::Base.deliveries.first

      expect(mail.text_part.body).to_not include expectedCC
      expect(mail.html_part.body).to_not include CGI::escape(expectedCC)
    end
  end
end
