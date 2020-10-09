# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  content    :text             default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :event do
    user
    content { Faker::Lorem.paragraph }

    trait :with_fake_created_at do
      created_at { Faker::Date.backward }
    end
  end
end
