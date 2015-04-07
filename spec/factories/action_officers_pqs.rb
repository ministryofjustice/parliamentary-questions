# == Schema Information
#
# Table name: action_officers_pqs
#
#  id                :integer          not null, primary key
#  pq_id             :integer          not null
#  action_officer_id :integer          not null
#  reason            :text
#  reason_option     :string(255)
#  updated_at        :datetime
#  created_at        :datetime
#  reminder_accept   :integer          default(0)
#  reminder_draft    :integer          default(0)
#  response          :string(255)      default("awaiting")
#

FactoryGirl.define do
  factory :action_officers_pq do
    action_officer

    factory :accepted_action_officers_pq do
      response 'accepted'
    end

    factory :rejected_action_officers_pq do
      response 'rejected'
    end
  end
end
