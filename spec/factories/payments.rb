# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  sender_id      :integer
#  receiver_id    :integer
#  sender_email   :string           not null
#  receiver_email :string           not null
#  amount         :float            default("0.0"), not null
#  description    :text             default(""), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryBot.define do
  factory :payment do
    sender
    receiver
    amount      { Faker::Number.between(from: 0.1, to: 999.99) }
    description { Faker::Lorem.paragraph }
  end
end
