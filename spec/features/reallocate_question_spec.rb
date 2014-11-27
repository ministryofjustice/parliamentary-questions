require 'spec_helper'

feature 'Reallocate question' do
  scenario 'allocate question to another action officer' do
    pq = create(:draft_pending_pq)
    sign_in

  end

  scenario 'reallocation option not shown when not in draft pending' do
    pq = create(:not_responded_pq)
  end
end

