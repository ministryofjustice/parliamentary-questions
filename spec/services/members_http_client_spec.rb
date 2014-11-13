require 'spec_helper'

describe MembersHttpClient do
  let(:url) { "http://data.parliament.uk/membersdataplatform/services/mnis/members/query/name*Diane%20Abbott/" }

  it 'gets an xml response from the Members API' do
    stub_request(:get, url).to_return(body: 'response')
    expect(subject.members_xml('Diane Abbott')).to eq('response')
  end

  it 'gets an array with the members from the Members API' do
    stub_request(:get, url).to_return(body: File.read('spec/fixtures/members.xml'))
    member = subject.members('Diane Abbott').first
    expect(member['DisplayAs']).to eq('Ms Diane Abbott')
    expect(member['Member_Id']).to eq('172')
  end
end
