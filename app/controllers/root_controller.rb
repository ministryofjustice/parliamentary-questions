class RootController < ApplicationController
  before_action :authenticate_user!

  def index
    return redirect_to controller: 'dashboard', action: 'index' if current_user.pq_user?
    return redirect_to controller: 'finance', action: 'questions' if current_user.finance_user?

    render file: 'public/401.html', status: :unauthorized
  end
end
