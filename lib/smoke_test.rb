module SmokeTest
#
# Module to run smoke tests against the staging/production environments
#

module_function

  ALL =
    [
      SmokeTest::Dashboard,
      SmokeTest::Report,
    ].freeze

  def factory
    ALL.map(&:from_env)
  end
end
