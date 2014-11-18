module Features
  module SessionHelpers
    def sign_in(user = nil, password = nil)
      password ||= password || 'password123'
      user ||= create(:user, password: password)

      visit '/users/sign_in'
      fill_in 'Email', with: user.email
      fill_in 'user_password', with: password
      click_button 'Sign in'
    end
  end
end
