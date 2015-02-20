module Features
  module SessionHelpers
    include Rails.application.routes.url_helpers

    def create_pq_session
      user = DBHelpers.users.find(&:pq_user?)
      sign_in(user.email, DBHelpers::USER_PASSWORD)
    end

    def create_finance_session
      user = DBHelpers.users.find(&:finance_user?)
      sign_in(user.email, DBHelpers::USER_PASSWORD)
    end

    def sign_in(email, password)
      visit destroy_user_session_path
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
