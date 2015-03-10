class InProgressStatusFilter < DashboardFilter
  include Rails.application.routes.url_helpers
  def active?
    @params[:controller] == 'dashboard' && @params[:action] == 'in_progress_by_status' &&
      @params[:qstatus] == @key
  end

  def path
    dashboard_in_progress_by_status_path(qstatus: @key)
  end
end
