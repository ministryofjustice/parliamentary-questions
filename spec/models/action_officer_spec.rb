require 'spec_helper'

describe ActionOfficer do
	let(:officer) {build(:action_officer)}

	it 'should pass factory build' do
		expect(officer).to be_valid
	end
	it 'should have a deputy director' do
		officer.deputy_director_id = nil
		expect(officer).to be_invalid
  end
  it 'should have a press desk' do
    officer.press_desk_id = nil
    expect(officer).to be_invalid
  end

  it 'should have return concatenated emails if group_email is set' do
    expect(officer.emails).to eql('action.officer@email.com')
    officer.group_email = 'group.email@email.com'
    expect(officer.emails).to eql('action.officer@email.com;group.email@email.com')
  end

  it 'should strip whitespace from emails' do
    officer.update(email:' action.officer@new.email.com')
    expect(officer.email).to eql('action.officer@new.email.com')

  end
  describe "associations" do
     
    it "should have a deputy director attribute" do
      @depdir = officer.should respond_to(:deputy_director)
    end
    it 'should have a collection of assignments' do
      officer.should respond_to(:action_officers_pqs)
    end
  end
end
