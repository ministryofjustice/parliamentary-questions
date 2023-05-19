class ProposalForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :pq_id, :action_officer_id, :action_officers

  before_validation :remove_blank_action_officer
  before_validation :load_valid_action_officers
  validates :pq_id, presence: { message: 'Please provide question id to proposal' }
  validates :action_officer_id, presence: { message: 'Please select at least one action officer' }
  validates :action_officers, presence: { message: 'Please select valid action officer' }

  def persisted?
    false
  end

  private

  def remove_blank_action_officer
    action_officer_id&.reject!(&:blank?)
  end

  def load_valid_action_officers
    return if action_officer_id.nil?

    @action_officers =
      action_officer_id.uniq.filter_map do |id|
        ActionOfficer.find_by(id:)
      end
  end
end
