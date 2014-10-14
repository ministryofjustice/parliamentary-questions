module UI
  module Sections
    class CommissionForm < SitePrism::Section
      # Fixme ids and classes in the actual form are not consistent,valid or are duplicated and have to me fixed
      element :minister, '#commission_form_minister_id'
      element :policy_minister, '#commission_form_policy_minister_id'
      element :action_officers, '.multi-select-action-officers'
      element :date_for_answer, '.date-for-answer'
      element :internal_deadline, '.internal-deadline'

      element :commission_button, '.commission-button'
    end
  end
end