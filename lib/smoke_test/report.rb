module SmokeTest
  class Report < Base
    private
    
    def all_checks_succeed?
      agent.get reports_press_desk_by_progress_path

      agent.page.code == '200' && !!(agent.page.body =~ /Press desk report/)
    end
  end
end