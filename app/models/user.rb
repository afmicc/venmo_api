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

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  def friends
    incoming_friends + outgoing_friends
  end
end
