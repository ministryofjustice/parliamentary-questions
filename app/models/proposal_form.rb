class ProposalForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :pq_id, :action_officer_id

  before_validation :remove_blank_action_officer
  validates :pq_id, presence: { message: 'Please provide question id to proposal' }
  validates :action_officer_id, presence: { message: 'Please select at least one action officer' }

  def persisted?
    false
  end

  private

  def remove_blank_action_officer
    action_officer_id&.reject!(&:blank?)
  end
end
