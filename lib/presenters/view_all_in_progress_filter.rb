module Presenters
  class ViewAllInProgressFilter < DashboardFilter
    include Rails.application.routes.url_helpers

    def active?
      @params[:controller] == 'dashboard' && 
        @params[:action] == 'in_progress' &&
          @params[:qstatus].blank?
    end

    def path
      dashboard_in_progress_path
    end
  end
end
