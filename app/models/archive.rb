class Archive < ApplicationRecord
  before_validation :downcase_prefix

  validates :prefix, presence: true, uniqueness: true
  validate :check_numeric

  def self.all_prefixes
    Archive.pluck(:prefix).join(", ")
  end

private

  def downcase_prefix
    self.prefix = prefix&.downcase
  end

  def check_numeric
    if prefix&.match?(/[[:digit:]]/)
      errors.add(:prefix, :invalid)
    end
  end
end
