World(Warden::Test::Helpers)

Before do
  Warden.test_mode!

  @user = FactoryGirl.create(:user)
  login_as(@user)
end

After do
  Warden.test_reset!
end

