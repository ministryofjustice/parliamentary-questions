module Metrics
  class PqaImport < Component
    attr_reader :last_run_time, :last_run_status, :pqs

    def initialize
      @pqs  = NumPqsImported.new
    end

    def collect!
      @last_run_time   = Time.use_zone('London') { last_run.start_time.in_time_zone }
      @last_run_status = last_run.status
      @pqs             = NumPqsImported.build
    end

    def report
      "#{pqs.today} :: #{pqs.this_week} :: #{pqs.this_month}"
    end

    private

    NumPqsImported = 
      Struct.new(:today, :this_week, :this_month) do 
        def self.build
          new( 
            PqaImportRun.sum_pqs_imported(:day),
            PqaImportRun.sum_pqs_imported(:week),
            PqaImportRun.sum_pqs_imported(:month)
          )
        end
      end

    def last_run
      PqaImportRun.last || create_empty_import_run
    end

    def create_empty_import_run
      PqaImportRun.new(
        start_time:     Time.at(0),
        end_time:       Time.at(0),
        status:         'FAIL',
        num_created:    0,
        num_updated:    0,
        error_messages: []
      )
    end
  end
end