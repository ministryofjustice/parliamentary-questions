require 'spec_helper'

describe 'MembersHttpClient' do

  before(:each) do
    @http_client = MembersHttpClient.new
  end

  # Mark as a pending because calls an external API
  xit 'should get an xml response from the Members API' do
    members_xml = @http_client.members_xml('Diane Abbott')
    members_xml.should include('<DisplayAs>Ms Diane Abbott</DisplayAs>')
    members_xml.should include('Member_Id="172"')
  end


  xit 'should get an array with the members from the Members API' do
    members = @http_client.members('Diane Abbott')
    members.first.should_not be nil
    diane = members.first
    diane['DisplayAs'].should eq('Ms Diane Abbott')
    diane['Member_Id'].should eq('172')
  end


end