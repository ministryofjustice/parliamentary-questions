class CommissionForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :pq_id, :minister_id, :policy_minister_id, :action_officer_id, :date_for_answer, :internal_deadline

  before_validation :remove_blank_action_officer
  validates :pq_id, presence: { message: t('page.message.select_commission_pq') }
  validates :minister_id, presence: { message: t('page.message.select_commission_minister') }
  validates :action_officer_id, presence: { message: t('page.message.select_commission_action_officer') }
  validates :date_for_answer, presence: { message: t('page.message.select_commission_date_for_answer') }
  validates :internal_deadline, presence: { message: t('page.message.select_commission_deadline') }

  def persisted?
    false
  end

  private

  def remove_blank_action_officer
    action_officer_id&.reject!(&:blank?)
  end
end
