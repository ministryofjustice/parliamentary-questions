module HostEnv
  extend self

  def is_staging?
   ENV['SENDING_HOST'] =~ /staging.pq.dsd.io/
  end

  def is_dev?
    ENV['SENDING_HOST'] =~ /dev.pq.dsd.io/
  end
end