module DashboardHelper
  def filter_active(state)
    'active' if ((params[:state] || 'view_all') == state.to_s)
  end

  def display_state_for(question)
    question.state_machine.state.to_s.gsub('_', ' ')
  end

  def state_class_for(question)
    "state-#{question.state_machine.state.to_s.dasherize}"
  end
end
