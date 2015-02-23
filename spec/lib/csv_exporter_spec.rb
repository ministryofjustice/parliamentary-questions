require 'spec_helper'

module Test
  class TestExporter < CSVExporter
    def pqs
      Pq.all
    end
  end
end

describe DefaultCSVExporter do
  
  
  
  it 'should'

end