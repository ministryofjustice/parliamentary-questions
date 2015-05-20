class MailWorker
  class PidFile
    attr_reader :path

    def initialize(path)
      @path    = path
    end

    def present?
      File.exists?(path)
    end

    def pid
      File.read(path)
    end

    def pid=(pid_s)
      FileUtils.mkdir_p(File.dirname(@path)) unless Dir.exist?(File.dirname(@path))
      File.open(path, 'w') { |f| f.write(pid_s) }
    end

    def delete(pid_s)
      if present? && pid == pid_s
        File.delete(path) 
      end
    end
  end
end