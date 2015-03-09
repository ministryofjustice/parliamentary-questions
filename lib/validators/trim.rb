module Validators
  module Trim
    SIGNATURE = '[TRIM Context Reference]'

    # Checks whether an uploaded trim file is valid or not.
    #
    # Note: defines valid as having .tr5 extension and starting with SIGNATURE.
    #
    # @param uloaded_file [ActionController::UploadedFile]
    # @return Boolean
    def self.valid_upload?(upload_io)
      upload_io && File.extname(upload_io.original_filename) == '.tr5' && matches_signature?(upload_io)
    end

    private_class_method
    def self.matches_signature?(upload_io)
      File.open(upload_io.path) do |f|
        line = f.readline
        !!line[SIGNATURE]
      end
    end
  end
end
