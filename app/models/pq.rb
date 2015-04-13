# == Schema Information
#
# Table name: pqs
#
#  id                                            :integer          not null, primary key
#  house_id                                      :integer
#  raising_member_id                             :integer
#  tabled_date                                   :datetime
#  response_due                                  :datetime
#  question                                      :text
#  answer                                        :string(255)
#  created_at                                    :datetime
#  updated_at                                    :datetime
#  finance_interest                              :boolean
#  seen_by_finance                               :boolean          default(FALSE)
#  uin                                           :string(255)
#  member_name                                   :string(255)
#  member_constituency                           :string(255)
#  house_name                                    :string(255)
#  date_for_answer                               :date
#  registered_interest                           :boolean
#  internal_deadline                             :datetime
#  question_type                                 :string(255)
#  minister_id                                   :integer
#  policy_minister_id                            :integer
#  progress_id                                   :integer
#  draft_answer_received                         :datetime
#  i_will_write_estimate                         :datetime
#  holding_reply                                 :datetime
#  preview_url                                   :string(255)
#  pod_waiting                                   :datetime
#  pod_query                                     :datetime
#  pod_clearance                                 :datetime
#  transferred                                   :boolean
#  question_status                               :string(255)
#  round_robin                                   :boolean
#  round_robin_date                              :datetime
#  i_will_write                                  :boolean
#  pq_correction_received                        :boolean
#  correction_circulated_to_action_officer       :datetime
#  pod_query_flag                                :boolean
#  sent_to_policy_minister                       :datetime
#  policy_minister_query                         :boolean
#  policy_minister_to_action_officer             :datetime
#  policy_minister_returned_by_action_officer    :datetime
#  resubmitted_to_policy_minister                :datetime
#  cleared_by_policy_minister                    :datetime
#  sent_to_answering_minister                    :datetime
#  answering_minister_query                      :boolean
#  answering_minister_to_action_officer          :datetime
#  answering_minister_returned_by_action_officer :datetime
#  resubmitted_to_answering_minister             :datetime
#  cleared_by_answering_minister                 :datetime
#  answer_submitted                              :datetime
#  library_deposit                               :boolean
#  pq_withdrawn                                  :datetime
#  holding_reply_flag                            :boolean
#  final_response_info_released                  :string(255)
#  round_robin_guidance_received                 :datetime
#  transfer_out_ogd_id                           :integer
#  transfer_out_date                             :datetime
#  directorate_id                                :integer
#  division_id                                   :integer
#  transfer_in_ogd_id                            :integer
#  transfer_in_date                              :datetime
#  follow_up_to                                  :string(255)
#  state                                         :string(255)      default("unassigned")
#  state_weight                                  :integer          default(0)
#

class Pq < ActiveRecord::Base
  has_paper_trail

  include PqFollowup
  extend PqScopes
  extend PqCounts

  has_one :trim_link, dependent: :destroy
  has_many :action_officers_pqs do
    def accepted
      where(response: 'accepted').first
    end

    def rejected
      where(response: 'rejected')
    end

    def all_rejected?
      all.find{ |assignment| !assignment.rejected? }.nil?
    end
  end

  has_many :action_officers, :through => :action_officers_pqs do
    def accepted
      where(action_officers_pqs: {response: 'accepted'}).first
    end

    def rejected
      where(action_officers_pqs: {response: 'rejected'})
    end
  end

  belongs_to :minister
  belongs_to :policy_minister, :class_name=>'Minister'
  belongs_to :transfer_out_ogd, :class_name=>'Ogd'
  belongs_to :transfer_in_ogd, :class_name=>'Ogd'
  belongs_to :directorate
  belongs_to :division

  accepts_nested_attributes_for :trim_link
  before_validation :strip_uin_whitespace

  validates :uin , presence: true, uniqueness:true
  validates :raising_member_id, presence:true
  validates :question, presence:true
  validate  :transfer_out_consistency

  RESPONSES = [
    "Commercial in confidence",
    "Disproportionate cost",
    "Full disclosure",
    "Holding reply [named day PQ only]",
    "I will write",
    "Information not held centrally",
    "Information not recorded",
    "Partial disclosure",
    "Partial Disproportionate cost",
    "Referral"
  ]
  validates :final_response_info_released, inclusion: RESPONSES, allow_nil: true, allow_blank: true

  before_update :set_pod_waiting, :set_state_weight

  def set_pod_waiting
    self.pod_waiting = draft_answer_received if draft_answer_received_changed?
  end

  def set_state_weight
    self.state_weight = PQState.state_weight(state)
  end

  def update_state!
    self.state = PQState.progress_changer.next_state(PQState::UNASSIGNED, self)
    self.save!
  end

  def reassign(action_officer)
    if action_officer
      Pq.transaction do
        ao_pq_accepted.reset
        action_officers_pqs.find_or_create_by(action_officer: action_officer).accept
        whodunnit("AO:#{action_officer.name}") do
          division = action_officer.deputy_director.try(:division)
          directorate = division.try(:directorate)
          update(directorate: directorate, division: division)
        end
      end
    end
  end

  def has_trim_link?
    trim_link.present? && !trim_link.deleted?
  end

  def strip_uin_whitespace
    uin && self.uin.strip!
  end

  def commissioned?
    action_officers.size > 0 &&
      action_officers.rejected.size != action_officers.size
  end

  def rejected?
    action_officers_pqs.all_rejected?
  end

  def no_response?
    action_officers_pqs.where("response != 'rejected'").any?
  end

  def only_rejected?
    !action_officers.accepted && action_officers.rejected.any?
  end

  def is_new?
    PQState::NEW.include?(state)
  end

  def closed?
    PQState::CLOSED.include?(state)
  end

  def open?
    !closed?
  end

  def is_unallocated?
    action_officers_pqs.count == 0
  end

  def action_officer_accepted
    action_officers.accepted
  end

  def ao_pq_accepted
    action_officers_pqs.accepted
  end

  def short_house_name
    if house_name.include?('Lords')
      'HoL'
    else
      'HoC'
    end
  end

  def deleted?
    !seen_by_finance?
  end

  private

  def transfer_out_consistency
    if ( !!transfer_out_date ^ !!transfer_out_ogd_id )
      errors[:base] << 'Invalid transfer out submission - requires BOTH date and department'
    end
  end

  def iww_uin
    "#{uin}-IWW" if uin.present? && !is_follow_up?
  end
end
