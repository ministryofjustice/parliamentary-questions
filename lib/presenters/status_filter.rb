module Presenters
  class StatusFilter < DashboardFilter
    include Rails.application.routes.url_helpers

    def active?
      @params[:controller] == 'dashboard' &&
        @params[:action] == 'by_status' &&
          @params[:qstatus] == @key
    end

    def path
      dashboard_by_status_path(qstatus: @key)
    end
  end
end
