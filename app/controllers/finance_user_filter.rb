class FinanceUserFilter
  def self.before(controller)
    controller.render file: 'public/401.html', status: :unauthorized unless has_access(controller)
  end

  def self.has_access(controller)
    controller.current_user.finance_user?
  end
end
