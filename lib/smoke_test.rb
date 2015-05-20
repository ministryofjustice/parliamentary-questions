module SmokeTest
  #
  # Module to run smoke tests against the staging/production environments
  #
  extend self

  ALL = 
  [ 
    SmokeTest::Dashboard,
    SmokeTest::Report,
    SmokeTest::Statistics
  ]

  def factory
    ALL.map(&:from_env)
  end
end