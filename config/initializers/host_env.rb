module HostEnv
  extend self

  def is_live?
    ENV.fetch('SENDING_HOST', nil) =~ /^trackparliamentaryquestions.service.gov.uk/
  end

  def is_staging?
    ENV.fetch('SENDING_HOST', nil) =~ /^staging.trackparliamentaryquestions.service.gov.uk/
  end

  def is_dev?
    ENV.fetch('SENDING_HOST', nil) =~ /^development.trackparliamentaryquestions.service.gov.uk/
  end
end
