module Features
  module SessionHelpers
    def create_pq_session
      user = DbHelpers.users.find(&:pq_user?)
      sign_in(user.email, DbHelpers::USER_PASSWORD)
      sleep 1
    end

    def create_admin_session
      user = DbHelpers.users.find(&:admin?)
      sign_in(user.email, DbHelpers::USER_PASSWORD)
      sleep 1
    end

    def sign_in(email, password)
      visit destroy_user_session_path
      visit new_user_session_path
      fill_in "Email", with: email
      fill_in "Password", with: password
      click_button "Sign in"
      sleep 1
    end
  end
end
