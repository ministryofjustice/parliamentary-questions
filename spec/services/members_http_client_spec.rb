require 'spec_helper'

describe 'MembersHttpClient' do

  before(:each) do
    @http_client = MembersHttpClient.new
  end

  # Mark as a pending because calls an external API
  xit 'should get an xml response from the Members API' do
    members_xml = @http_client.members('Diane Abbott')
    members_xml.should include('<DisplayAs>Ms Diane Abbott</DisplayAs>')
    members_xml.should include('Member_Id="172"')
  end

end