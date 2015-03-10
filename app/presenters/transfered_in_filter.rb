class TransferedInFilter < DashboardFilter
  include Rails.application.routes.url_helpers

  def active?
    @params[:controller] == 'dashboard' && @params[:action] == 'transferred'
  end

  def path
    dashboard_transferred_path
  end
end
