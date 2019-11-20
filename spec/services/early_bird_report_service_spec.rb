require 'spec_helper'

describe 'EarlyBirdReportService' do
  let!(:early_bird_one)     { create(:early_bird_member, name: 'member 1', email: 'm1@ao.gov', deleted: false) }
  let!(:early_bird_two)     { create(:early_bird_member, name: 'member 2', email: 'm2@ao.gov', deleted: false) }
  let!(:early_bird_deleted) { create(:early_bird_member, name: 'member 3', email: 'm3@ao.gov', deleted: true) }
  let(:testid)              { 'early_bird-' + DateTime.now.to_s }

  before(:each) do
    @report_service = EarlyBirdReportService.new
  end

  it 'should have generated a valid token' do
    @report_service.notify_early_bird

    token = Token.find_by(entity: @report_service.entity, path: '/early_bird/dashboard')
    expect(token.token_digest).to_not be nil

    end_of_day = DateTime.current.end_of_day

    expect(token.expire.to_s).to eq(end_of_day.to_s)
    expect(
      Token.exists?(entity: "early_bird:#{early_bird_deleted.id}", path: '/early_bird/dashboard')
    ).to eq(false)
  end

  it 'calls the mailer' do
    allow(NotifyPqMailer).to receive_message_chain(:early_bird_email, :deliver_now)

    token = @report_service.notify_early_bird

    expect(NotifyPqMailer).to have_received(:early_bird_email).with(email: 'm1@ao.gov;m2@ao.gov', entity: testid, token: token)
    expect(NotifyPqMailer).not_to have_received(:early_bird_email).with(email: 'm3@ao.gov')
  end
end
