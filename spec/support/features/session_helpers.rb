module Features
  module SessionHelpers
    
    def create_pq_session
      UserBuilder.create_pq
      sign_in(UserBuilder::EMAILS.fetch(:pq), UserBuilder::PASS)
    end

    def create_finance_session
      UserBuilder.create_finance
      sign_in(UserBuilder::EMAILS.fetch(:finance), UserBuilder::PASS)
    end

    def sign_in(email, password)
      visit '/users/sign_out'
      visit '/users/sign_in'
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
