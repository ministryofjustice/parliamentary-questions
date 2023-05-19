module PQUserFilter
  extend self

  def before(controller)
    controller.render file: 'public/401.html', status: :unauthorized unless has_access(controller)
  end

  def has_access(controller)
    controller.current_user.pq_user?
  end
end
