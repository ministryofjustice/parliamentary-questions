module SmokeTest
  class Statistics < Base
    private
    
    def all_checks_succeed?
      agent.get statistics_stages_time_path

      agent.page.code == '200' && 
        !!(agent.page.body =~ /Question duration in phases/)
    end
  end
end