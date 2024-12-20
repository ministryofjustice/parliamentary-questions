# == Schema Information
#
# Table name: pqs
#
#  id                            :integer          not null, primary key
#  house_id                      :integer
#  raising_member_id             :integer
#  tabled_date                   :datetime
#  response_due                  :datetime
#  question                      :text
#  answer                        :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  uin                           :string
#  member_name                   :string
#  member_constituency           :string
#  house_name                    :string
#  date_for_answer               :date
#  registered_interest           :boolean
#  internal_deadline             :datetime
#  question_type                 :string
#  minister_id                   :integer
#  policy_minister_id            :integer
#  progress_id                   :integer
#  draft_answer_received         :datetime
#  holding_reply                 :datetime
#  preview_url                   :string
#  pod_waiting                   :datetime
#  pod_clearance                 :datetime
#  transferred                   :boolean
#  question_status               :string
#  sent_to_policy_minister       :datetime
#  cleared_by_policy_minister    :datetime
#  sent_to_answering_minister    :datetime
#  cleared_by_answering_minister :datetime
#  answer_submitted              :datetime
#  final_response_info_released  :string
#  transfer_out_ogd_id           :integer
#  transfer_out_date             :datetime
#  directorate_id                :integer
#  original_division_id          :integer
#  transfer_in_ogd_id            :integer
#  transfer_in_date              :datetime
#  state                         :string           default("unassigned")
#  state_weight                  :integer          default(0)
#  archived                      :boolean          default(FALSE)
#

class Pq < ApplicationRecord
  belongs_to :progress

  has_paper_trail

  extend PqScopes
  extend PqCounts

  has_one :trim_link, dependent: :destroy
  has_many :action_officers_pqs do
    def accepted
      find_by(response: "accepted")
    end

    def rejected
      where(response: "rejected")
    end

    def not_rejected
      where.not(response: "rejected")
    end

    def all_rejected?
      all.find { |assignment| !assignment.rejected? }.nil?
    end
  end

  has_many :action_officers, through: :action_officers_pqs do
    def all_accepted
      where(action_officers_pqs: { response: "accepted" })
    end

    def accepted
      find_by(action_officers_pqs: { response: "accepted" })
    end

    def rejected
      where(action_officers_pqs: { response: "rejected" })
    end

    def not_rejected
      where.not(action_officers_pqs: { response: "rejected" })
    end
  end

  belongs_to :minister
  belongs_to :policy_minister, class_name: "Minister"
  belongs_to :transfer_out_ogd, class_name: "Ogd"
  belongs_to :transfer_in_ogd, class_name: "Ogd"
  belongs_to :directorate, class_name: "Directorate"
  belongs_to :original_division, class_name: "Division"

  accepts_nested_attributes_for :trim_link
  before_validation :strip_uin_whitespace

  validates :uin, presence: true, uniqueness: true
  validates :uin, presence: true
  validates :raising_member_id, presence: true
  validates :question, presence: true
  validate  :transfer_out_consistency
  validate  :sole_accepted_action_officer
  before_update :set_pod_waiting, :set_state_weight

  scope :unarchived, -> { where(archived: false) }

  def set_pod_waiting
    self.pod_waiting = draft_answer_received if draft_answer_received_changed?
  end

  def set_state_weight
    self.state_weight = PqState.state_weight(state)
  end

  def update_state!
    self.state = PqState.progress_changer.next_state(PqState::UNASSIGNED, self)
    save!
  end

  def reassign(action_officer)
    if action_officer
      Pq.transaction do
        ao_pq_accepted.reset
        action_officers_pqs.find_or_create_by!(action_officer:).accept
        PaperTrail.request(whodunnit: "AO:#{action_officer.name}") do
          original_division = action_officer.deputy_director.try(:division)
          directorate = original_division.try(:directorate)
          update!(directorate:, original_division:)
        end
      end
    end
  end

  def has_trim_link?
    trim_link.present? && !trim_link.deleted?
  end

  def strip_uin_whitespace
    uin&.strip!
  end

  def commissioned?
    !action_officers.empty? &&
      action_officers.rejected.size != action_officers.size &&
      internal_deadline.present?
  end

  def proposed?
    action_officers.present? and !commissioned?
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
    PqState::NEW.include?(state)
  end

  def closed?
    PqState::CLOSED.include?(state)
  end

  def open?
    !closed?
  end

  def is_unallocated?
    action_officers_pqs.count.zero?
  end

  def action_officer_accepted
    action_officers.accepted
  end

  def ao_pq_accepted
    action_officers_pqs.accepted
  end

  def short_house_name
    if house_name.include?("Lords")
      "HoL"
    else
      "HoC"
    end
  end

  def question_type_header
    header = ""
    header += "| Ordinary" if question_type == "Ordinary"
    header += "| Named Day" if question_type == "NamedDay"
    header += " | Transferred in" if transferred?
    header
  end

private

  def sole_accepted_action_officer
    errors.add(:base, :sole_accepted_action_officer, message: "Unable to have two action officers accepted on the same question") if action_officers.all_accepted.size > 1
  end

  def transfer_out_consistency
    errors.add(:base, :transfer_out_consistency, message: "Invalid transfer out submission - requires BOTH date and department") if !!transfer_out_date ^ !!transfer_out_ogd_id
  end
end
