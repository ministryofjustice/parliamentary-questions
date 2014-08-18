module ApplicationHelper
  def flash_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end


  def version_number
    ENV['APPVERSION']
  end

  def build_time
    ENV['APP_BUILD_TIME'] || 'unknown'
  end

  def commit_id
    ENV['APP_COMMIT_ID'] || 'unknown'
  end


end
