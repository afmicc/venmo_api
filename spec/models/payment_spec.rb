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

require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:sender_email) }
    it { is_expected.to validate_presence_of(:receiver_email) }
    it { is_expected.to validate_numericality_of(:amount).is_greater_than(0).is_less_than(1_000) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:sender).class_name('User') }
    it { is_expected.to belong_to(:receiver).class_name('User') }
  end
end
