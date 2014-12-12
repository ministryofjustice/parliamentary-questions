module DashboardHelper
  def filter_active(state)
    'active' if ((params[:state] || 'view_all') == state.to_s)
  end

  def display_state_for(question)
    display_state(question.state_machine.state)
  end

  def display_state(state)
    state.to_s.humanize.gsub(/pod/i, 'POD')
  end

  def state_class_for(question)
    state_class(question.state_machine.state)
  end

  def state_class(state)
    "state-#{state.to_s.dasherize}"
  end
end
