
require 'spec_helper'

describe 'roles filer' do

  let!(:pq_user) { create(:user, name: 'pquser', email:'pq@admin.com', password: 'password123') }
  let!(:finance_user) { create(:user, name: 'finance', email:'f@admin.com', password: 'password123', roles: User.ROLE_FINANCE) }
  let!(:fake_role_user) { create(:user, name: 'fake', email:'m@admin.com', password: 'password123', roles: 'BAD') }

  before(:each) do
    @token_service = TokenService.new
  end

  it 'PQUserFilter should allow to access a user with a PQ ROLE' do
    controller = double('ApplicationController')

    allow(controller).to receive(:current_user) { User.find_by_name('pquser') }

    has_access = PQUserFilter.has_access(controller)

    has_access.should eq(true)
  end

  it 'PQUserFilter should not allow to access a user without a PQ ROLE' do
    controller = double('ApplicationController')

    allow(controller).to receive(:current_user) { User.find_by_name('fake') }

    has_access = PQUserFilter.has_access(controller)

    has_access.should eq(false)
  end

  it 'FinanceUserFilter should allow to access a user with a Finance ROLE' do
    controller = double('ApplicationController')

    allow(controller).to receive(:current_user) { User.find_by_name('finance') }

    has_access = FinanceUserFilter.has_access(controller)

    has_access.should eq(true)
  end

  it 'FinanceUserFilter should not allow to access a user without a Finance ROLE' do
    controller = double('ApplicationController')

    allow(controller).to receive(:current_user) { User.find_by_name('pquser') }

    has_access = FinanceUserFilter.has_access(controller)

    has_access.should eq(false)
  end

end
