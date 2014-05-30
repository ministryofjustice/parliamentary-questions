require 'spec_helper'

describe "action_officers/new" do
  before(:each) do
    assign(:action_officer, stub_model(ActionOfficer,
      :name => "MyString",
      :email => "MyString"
    ).as_new_record)
  end

  it "renders new action_officer form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", action_officers_path, "post" do
      assert_select "input#action_officer_name[name=?]", "action_officer[name]"
      assert_select "input#action_officer_email[name=?]", "action_officer[email]"
    end
  end
end
