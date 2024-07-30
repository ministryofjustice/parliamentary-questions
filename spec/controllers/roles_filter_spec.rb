require "rails_helper"

describe "roles filer" do
  before do
    create(:user, name: "pquser", email: "pq@admin.com", password: "password123")
    create(:user, name: "fake", email: "m@admin.com", password: "password123", roles: "BAD")
    @token_service = TokenService.new
  end

  it "PqUserFilter should allow to access a user with a PQ ROLE" do
    controller = instance_double("ApplicationController")

    allow(controller).to receive(:current_user) { User.find_by(name: "pquser") }

    has_access = PqUserFilter.has_access(controller)

    expect(has_access).to eq(true)
  end

  it "PqUserFilter should not allow to access a user without a PQ ROLE" do
    controller = instance_double("ApplicationController")

    allow(controller).to receive(:current_user) { User.find_by(name: "fake") }

    has_access = PqUserFilter.has_access(controller)

    expect(has_access).to eq(false)
  end
end
