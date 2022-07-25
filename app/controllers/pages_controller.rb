class PagesController < ApplicationController
  def accessibility
    update_page_title 'Accessibility statement'
  end
end