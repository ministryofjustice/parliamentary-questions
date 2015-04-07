# == Schema Information
#
# Table name: trim_links
#
#  id         :integer          not null, primary key
#  filename   :string(255)
#  size       :integer
#  data       :binary
#  pq_id      :integer
#  created_at :datetime
#  updated_at :datetime
#  deleted    :boolean          default(FALSE)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :trim_link do
    filename "trim_link.tr5"
    size 1
    data "binarydata?"
    pq_id 1
  end
end
