module UserBuilder
  PASS    =   '123456789'
  
  EMAILS  = {
    pq:       'pq@pq.com',
    finance:  'fin@fin.com'
  }

  module_function

  def create_pq
    create_custom(EMAILS[:pq],
                  PASS,
                  'Finance User')
  end

  def create_finance
    create_custom(EMAILS[:finance],
                  PASS,
                  'Finance User',
                  User::ROLE_FINANCE)
  end

  def create_custom(email, password, name, role = User::ROLE_PQ_USER)
    User.first_or_create!(email: email,
                          password: password,
                          password_confirmation: password,
                          name: name,
                          deleted: false,
                          roles: role)
  end
end
