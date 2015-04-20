module HostEnv
  extend self

  def is_staging?
   ENV['SENDING_HOST'] =~ /staging/
  end
end