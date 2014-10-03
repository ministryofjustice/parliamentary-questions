class CommissionForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :minister_id
  attr_accessor :policy_minister_id
  attr_accessor :action_officer_id
  attr_accessor :date_for_answer
  attr_accessor :internal_deadline

  before_validation :remove_blank_action_officer
  validates :minister_id, presence: {message: 'Please select answering minister'}
  validates :action_officer_id, presence: {message: 'Please select at least one action officer'}
  validates :date_for_answer, presence: {message: 'Please choose date for answer'}
  validates :internal_deadline, presence: {message: 'Please choose internal deadline'}

  def persisted?
    false
  end

  private

  def remove_blank_action_officer
    action_officer_id.reject!(&:blank?) unless action_officer_id.nil?
  end
end