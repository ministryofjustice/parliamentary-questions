require_relative '../sections/commission_form'

module UI
  module Pages
    class Dashboard < SitePrism::Page
      set_url 'dashboard'

      section :commission_form, UI::Sections::CommissionForm, '.form-commission'
    end
  end
end