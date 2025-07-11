module Features
  module SessionHelpers
    def create_pq_session
      user = DbHelpers.users.find(&:pq_user?)
      sign_in(user.email, DbHelpers::USER_PASSWORD)
    end

    def create_admin_session
      user = DbHelpers.users.find(&:admin?)
      sign_in(user.email, DbHelpers::USER_PASSWORD)
    end

    def sign_in(email, password)
      visit destroy_user_session_path
      visit new_user_session_path
      fill_in "Email (required)", with: email
      fill_in "Password (required)", with: password
      click_button "Sign in"
    end
  end
end
