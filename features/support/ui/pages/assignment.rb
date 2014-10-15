module UI
  module Pages
    class Assignment < SitePrism::Page
      set_url '/assignment/{uin}?token={token}&entity={entity}'

      element :accept, '#allocation_response_response_action_accept'
      element :reject, '#allocation_response_response_action_reject'
      element :reject_reason_option, '#new_allocation_response select'
      element :reject_reason_text, '#allocation_response_reason'
      element :save, '.button'
    end
  end
end