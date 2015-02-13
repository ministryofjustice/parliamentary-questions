require 'spec_helper'

describe 'WatchlistReportService' do

  let!(:watchlist_one) { create(:watchlist_member, name: 'member 1', email: 'm1@ao.gov',  deleted: false) }
  let!(:watchlist_two) { create(:watchlist_member, name: 'member 2', email: 'm2@ao.gov', deleted: false) }
  let!(:watchlist_deleted) { create(:watchlist_member, name: 'member 3', email: 'm3@ao.gov', deleted: true) }
  let(:testid) { "watchlist-" + DateTime.now.to_s }

  before(:each) do
    @report_service = WatchlistReportService.new
    ActionMailer::Base.deliveries = []
  end

  it 'should have generated a valid token' do
    @report_service.notify_watchlist

    token = Token.find_by(entity: @report_service.entity, path: '/watchlist/dashboard')
    expect(token.token_digest).to_not be nil

    end_of_day = DateTime.now.end_of_day
    expect(token.expire).to eq(end_of_day)

    expect(
      Token.exists?(entity: "watchlist:#{watchlist_deleted.id}", path: '/watchlist/dashboard')
    ).to eq(false)
  end

  it 'should send an email with the right data' do
    pqtest_mail ='pqtest@digital.justice.gov.uk'

    allow(@report_service).to receive(:entity).and_return testid
    result = @report_service.notify_watchlist

    mail = ActionMailer::Base.deliveries.first

    sentToken = result[pqtest_mail]
    token_param = {token: sentToken}.to_query
    entity = {entity: entity = testid }.to_query
    url = '/watchlist/dashboard'

    expect(mail.html_part.body).to include url
    expect(mail.html_part.body).to include token_param
    expect(mail.html_part.body).to include entity


    expect(mail.text_part.body).to include url
    expect(mail.text_part.body).to include token_param
    expect(mail.text_part.body).to include entity

    expect(mail.to).to include pqtest_mail

  end

  it 'should add the people from the Watchlist to the CC' do
    allow(@report_service).to receive(:entity).and_return testid
    result = @report_service.notify_watchlist

    mail = ActionMailer::Base.deliveries.first
    sentToken = result[watchlist_one.id]
    token_param = {token: sentToken}.to_query
    entity = {entity: entity = testid }.to_query
    url = '/watchlist/dashboard'

    expect(mail.cc).to include watchlist_one.email
    expect(mail.cc).to include watchlist_two.email
  end
end
