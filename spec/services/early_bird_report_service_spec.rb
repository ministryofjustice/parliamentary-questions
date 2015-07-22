require 'spec_helper'

describe 'EarlyBirdReportService' do

  let!(:early_bird_one) { create(:early_bird_member, name: 'member 1', email: 'm1@ao.gov',  deleted: false) }
  let!(:early_bird_two) { create(:early_bird_member, name: 'member 2', email: 'm2@ao.gov', deleted: false) }
  let!(:early_bird_deleted) { create(:early_bird_member, name: 'member 3', email: 'm3@ao.gov', deleted: true) }
  let(:testid) { "early_bird-" + DateTime.now.to_s }

  before(:each) do
    @report_service               = EarlyBirdReportService.new
    ActionMailer::Base.deliveries = []
  end

  it 'should have generated a valid token' do
    @report_service.notify_early_bird

    token = Token.find_by(entity: @report_service.entity, path: '/early_bird/dashboard')
    expect(token.token_digest).to_not be nil

    end_of_day = DateTime.now.end_of_day
    expect(token.expire).to eq(end_of_day)

    expect(
      Token.exists?(entity: "early_bird:#{early_bird_deleted.id}", path: '/early_bird/dashboard')
    ).to eq(false)
  end


    it 'should send an email with the right data' do
      pqtest_mail ='pqtest@digital.justice.gov.uk'

      allow(@report_service).to receive(:entity).and_return testid
      result = @report_service.notify_early_bird

      MailWorker.new.run!
      mail = ActionMailer::Base.deliveries.first

      sentToken   = result[pqtest_mail]
      token_param = {token: sentToken}.to_query
      entity      = {entity: entity = testid }.to_query
      url         = '/early_bird/dashboard'


      expect(mail.to_s).to include url
      expect(mail.to_s).to include token_param
      expect(mail.to_s).to include entity

      expect(mail.to).to include pqtest_mail

    end


  it 'should add the people from the Early Bird to the CC' do
    allow(@report_service).to receive(:entity).and_return testid
    result = @report_service.notify_early_bird

    MailWorker.new.run!
    mail = ActionMailer::Base.deliveries.first

    sentToken   = result[early_bird_one.id]
    token_param = {token: sentToken}.to_query
    entity      = {entity: entity = testid }.to_query
    url         = '/early_bird/dashboard'

    expect(mail.cc).to include early_bird_one.email
    expect(mail.cc).to include early_bird_two.email
  end
end
