class PQAnswer
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :text, :is_holding_answer, :pq_id

  # validates_presence_of :text, :is_holding_answer
  validates :text, :is_holding_answer, presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      public_send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
