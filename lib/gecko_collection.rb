require_relative 'gecko_status'

class GeckoCollection
  attr_reader :key_metric,
              :db,
              :pqa_api,
              :pqa_import,
              :smoke_tests

  def initialize
    @key_metric  = KeyMetricStatus.new
    @db          = DbStatus.new
    @pqa_api     = PqaApiStatus.new
    @pqa_import  = PqaImportStatus.new
    @smoke_tests = SmokeTestStatus.new
  end

  def map(&block)
    all.map do |gecko_status|
      block.call(gecko_status)
    end
  end

  def each(&block)
    all.each do |gecko_status|
      block.call(gecko_status)
    end
  end

  def update(components)
    map { |status| status.update(components) }
  end

  private

  def all
    [@key_metric, @db, @pqa_api, @pqa_import, @smoke_tests]
  end
end
