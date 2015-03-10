class IwwFilter < DashboardFilter
  include Rails.application.routes.url_helpers

  def active?
    @params[:controller] == 'dashboard' && @params[:action] == 'i_will_write'
  end

  def path
    dashboard_iww_path
  end
end
