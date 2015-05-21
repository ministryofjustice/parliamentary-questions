module SmokeTest
  class Dashboard < Base
    private
    
    def all_checks_succeed?
      agent.page.code == '200' && 
        agent.page.uri.path == dashboard_path &&
          !!(agent.page.body =~ /Filter/)
    end
  end
end
