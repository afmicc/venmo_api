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

class Payment < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  validates :amount, presence: true, numericality: { greater_than: 0, less_than: 1_000 }
  validates :sender_email, :receiver_email, presence: true

  before_validation :init_user_emails, on: :create

  private

  def init_user_emails
    self.sender_email = sender&.email
    self.receiver_email = receiver&.email
  end
end
