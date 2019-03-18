require 'spec_helper'

describe Export::PqDefault do
  include Unit::QuestionFactory
  include CSVHelpers

  let(:export) { Export::PqDefault.new(Date.yesterday, Time.zone.today) }

  context 'For output to Excel' do
    it 'Inserts a single quote to escape a formula in Excel' do
      expect(export.escape_equals_for_excel('=HYPERLINK("http://www.somedodgysite.com/","Innocuous Looking Link")')).to eq("'" + '=HYPERLINK("http://www.somedodgysite.com/","Innocuous Looking Link")')
    end
    it "Doesn't alter a value if it doesn't start with an equals" do
      expect(export.escape_equals_for_excel('HYPERLINK("http://www.somedodgysite.com/","Innocuous Looking Link")')).to eq('HYPERLINK("http://www.somedodgysite.com/","Innocuous Looking Link")')
    end
  end

  context 'when no records are present' do
    it 'returns a blank CSV' do
      expect(decode_csv(export.to_csv)).to eq []
    end
  end

  context 'when some records are present' do
    before(:each) do
      # Expected exclusions
      mk_pq('uin-1', answer_submitted: Time.zone.today - 5)
      mk_pq('uin-2', tabled_date: Time.zone.today + 1)
      mk_pq('uin-3', transfer_out_ogd_id: 1, transfer_out_date: Time.zone.today)

      # Expected inclusions
      mk_pq('uin-z')
      mk_pq('uin-a')
      mk_pq('uin-c')
    end

    it 'returns unanswered, and non transfered-out pqs, within the supplied date range ordered by UIN' do
      today        = date_s(Time.zone.today)
      yesterday    = date_s(Date.yesterday)
      exported_pqs =
        decode_csv(export.to_csv).map do |h|
          [
            h['PIN'],
            h['Full_PQ_subject'],
            h['Date First Appeared in Parliament'],
            h['Date response answered by Parly (dept)']
          ]
        end

      expect(exported_pqs).to eq([
                                   ['uin-a', 'uin-a body text', yesterday, today],
                                   ['uin-c', 'uin-c body text', yesterday, today],
                                   ['uin-z', 'uin-z body text', yesterday, today]
                                 ])
    end
  end
end
