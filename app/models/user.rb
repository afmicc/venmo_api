# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string           default(""), not null
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ApplicationRecord
  has_many :outgoing_friendships, class_name: 'Friendship', inverse_of: :user,
                                  dependent: :destroy
  has_many :incoming_friendships, foreign_key: :friend_id, class_name: 'Friendship',
                                  inverse_of: :friend, dependent: :destroy
  has_many :outgoing_friends, through: :outgoing_friendships, source: :friend
  has_many :incoming_friends, through: :incoming_friendships, source: :user

  has_many :received_payments, -> { where(receiver: user) },
           class_name: 'Payment',
           dependent: :nullify,
           inverse_of: :receiver
  has_many :sent_payments, -> { where(sender: user) },
           class_name: 'Payment',
           dependent: :nullify,
           inverse_of: :sender

  has_one :account, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  after_create :create_account

  def friends
    incoming_friends + outgoing_friends
  end

  def contacts_for_feed
    contacts = [id]
    contacts += friends.pluck(:id)
    Friendship.friendships_of(contacts)
              .pluck(:user_id, :friend_id)
              .flatten
              .uniq
  end

  private

  def create_account
    Account.create!(user: self)
  end
end
