module HostEnv
  extend self

  def is_live?
    ENV['SENDING_HOST'] =~ /trackparliamentaryquestions.service.gov.uk/
  end

  def is_staging?
    ENV['SENDING_HOST'] =~ /parliamentary-questions-staging.apps.live-1.cloud-platform.service.justice.gov.uk/
  end

  def is_dev?
    ENV['SENDING_HOST'] =~ /development.trackparliamentaryquestions.service.gov.uk/
  end
end
