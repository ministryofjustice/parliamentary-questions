require "spec_helper"

describe "roles filer" do
  before do
    create(:user, name: "pquser", email: "pq@admin.com", password: "password123")
    create(:user, name: "finance", email: "f@admin.com", password: "password123", roles: User::ROLE_FINANCE)
    create(:user, name: "fake", email: "m@admin.com", password: "password123", roles: "BAD")
    @token_service = TokenService.new
  end

  it "PQUserFilter should allow to access a user with a PQ ROLE" do
    controller = instance_double("ApplicationController")

    allow(controller).to receive(:current_user) { User.find_by(name: "pquser") }

    has_access = PQUserFilter.has_access(controller)

    expect(has_access).to eq(true)
  end

  it "PQUserFilter should not allow to access a user without a PQ ROLE" do
    controller = instance_double("ApplicationController")

    allow(controller).to receive(:current_user) { User.find_by(name: "fake") }

    has_access = PQUserFilter.has_access(controller)

    expect(has_access).to eq(false)
  end

  it "FinanceUserFilter should allow to access a user with a Finance ROLE" do
    controller = instance_double("ApplicationController")

    allow(controller).to receive(:current_user) { User.find_by(name: "finance") }

    has_access = FinanceUserFilter.has_access(controller)

    expect(has_access).to eq(true)
  end

  it "FinanceUserFilter should not allow to access a user without a Finance ROLE" do
    controller = instance_double("ApplicationController")

    allow(controller).to receive(:current_user) { User.find_by(name: "pquser") }

    has_access = FinanceUserFilter.has_access(controller)

    expect(has_access).to eq(false)
  end
end
