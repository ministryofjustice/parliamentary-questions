module DashboardHelper
  def active(state)
    'active' if (params[:state] == state.to_s)
  end
end
