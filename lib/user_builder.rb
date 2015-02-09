module UserBuilder
  PASS    =   '123456789'
  EMAILS  = {
    pq:       'pq@pq.com',
    finance:  'fin@fin.com'
  }

  module_function

  def create_pq
    create(EMAILS[:pq],
           PASS,
           'Test User')
  end

  def create_finance
    create(EMAILS[:finance],
           PASS,
           'Finance User',
           User::ROLE_FINANCE)
  end

  def create(email, password, name, role = User::ROLE_PQ_USER)
    u = User.find_or_initialize_by(email: email,
                                   name: name,
                                   deleted: false,
                                   roles: role)

    u.password              = password
    u.password_confirmation = password
    u.save
    u
  end
end
