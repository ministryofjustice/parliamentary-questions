class FinanceUserFilter
  def self.before(controller)
    if !has_access(controller)
      controller.render :file => "public/401.html", :status => :unauthorized
    end
  end

  def self.has_access(controller)
    controller.current_user.finance_user?
  end
end
