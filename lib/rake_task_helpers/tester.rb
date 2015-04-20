module RakeTaskHelpers
  class Tester
    attr_reader :name, :email, :domain, :pass, :prefix

    def self.factory(testers_h, default_pass, prefix)
      testers_h.map do |tester| 
        new(
          tester['name'],
          tester['email'],
          tester['domain'],
          default_pass,
          prefix
        )
      end
    end

    def initialize(name, email, domain, pass, prefix)
      @name   = name
      @email  = email
      @domain = domain
      @pass   = pass
      @prefix = prefix
    end

    def create_fixtures!
      u  =  
        User.find_or_create_by(
          email: email_for('u'), 
          name:  display_name, 
          roles: 'PQUSER'
        )

      u.update(
        password:              pass, 
        password_confirmation: pass
      ) if u.new_record?
    end

    protected

    def display_name
      "#{prefix} - #{name}"
    end

    def email_for(abbreviation)
       "#{email}+#{abbreviation}@#{domain}"
    end
  end

  class RestrictedTester < Tester
    private

    def email_for(abbreviation)
       "#{email}@#{domain}"
    end
  end

  class FullTester < Tester
    def create_fixtures!
      super

      Minister.find_or_create_by(
        name:  display_name, 
        title: prefix
      )

      p  = PressDesk.find_or_create_by(name: prefix)

      PressOfficer.find_or_create_by(
        name:       display_name, 
        email:      email_for('po'), 
        press_desk: p 
      )

      dir = Directorate.find_or_create_by(name: prefix)

      div = Division.find_or_create_by(
              name:        prefix, 
              directorate: dir
            )

      dd  = DeputyDirector.find_or_create_by( 
              division: div, 
              email:    email_for('dd'), 
              name:     display_name
            ) 

      ActionOfficer.find_or_create_by(
        deputy_director: dd, 
        name:            display_name, 
        email:           email_for('ao'),
        press_desk:      p 
      )
    end
  end
end