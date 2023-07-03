require "spec_helper"

describe "WatchlistReportService" do
  let!(:watchlist_one) { create(:watchlist_member, name: "member 1", email: "m1@ao.gov", deleted: false) }
  let!(:watchlist_two) { create(:watchlist_member, name: "member 2", email: "m2@ao.gov", deleted: false) }
  let!(:watchlist_deleted) { create(:watchlist_member, name: "member 3", email: "m3@ao.gov", deleted: true) }
  let(:testid) { "watchlist-" + DateTime.now.utc.to_s }

  before do
    @report_service = WatchlistReportService.new
  end

  it "has generated a valid token" do
    @report_service.notify_watchlist

    token = Token.find_by(entity: @report_service.entity, path: "/watchlist/dashboard")
    expect(token.token_digest).not_to be nil

    end_of_day = DateTime.current.end_of_day

    expect(token.expire.to_s).to eq(end_of_day.to_s)
    expect(
      Token.exists?(entity: "watchlist:#{watchlist_deleted.id}", path: "/watchlist/dashboard"),
    ).to eq(false)
  end

  it "calls the mailer" do
    allow(NotifyPqMailer).to receive_message_chain(:watchlist_email, :deliver_later)

    token = @report_service.notify_watchlist

    expect(NotifyPqMailer).to have_received(:watchlist_email).with(email: "m1@ao.gov", token:, entity: testid)
    expect(NotifyPqMailer).to have_received(:watchlist_email).with(email: "m2@ao.gov", token:, entity: testid)
    expect(NotifyPqMailer).not_to have_received(:watchlist_email).with(email: "m3@ao.gov")
  end
end
