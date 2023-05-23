class PagesController < ApplicationController
  def accessibility
    update_page_title t('page.title.accessibility_statement')
  end
end
