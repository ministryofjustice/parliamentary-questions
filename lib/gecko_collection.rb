class GeckoCollection

  attr_reader :db, :sendgrid, :pqa_api, :mail, :pqa_import

  def initialize
    @db         = GeckoStatus.new('Database')
    @sendgrid   = GeckoStatus.new('Sendgrid')
    @pqa_api    = GeckoStatus.new('PQA API')
    @mail       = GeckoStatus.new('Email')
    @pqa_import = GeckoStatus.new('PQ Import') 
  end

  def each(&block)
    [@db, @sendgrid, @pqa_api, @mail, @pqa_import].each do |gecko_status|
      block.call(gecko_status)
    end
  end


end