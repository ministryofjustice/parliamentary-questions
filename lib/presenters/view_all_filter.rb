module Presenters
  class ViewAllFilter < DashboardFilter
    include Rails.application.routes.url_helpers

    def active?
      @params[:controller] == 'dashboard' && @params[:action] == 'index' &&
        @params[:qstatus].blank?
    end

    def path
      dashboard_path
    end
  end
end
