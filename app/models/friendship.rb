# == Schema Information
#
# Table name: friendships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  friend_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  validate :friendship_already_exists, on: :create

  private

  def friendship_already_exists
    friendship_exists = Friendship.where(user: user, friend: friend)
                                  .or(Friendship.where(user: friend, friend: user))
                                  .exists?

    return unless friendship_exists

    errors.add(:base, I18n.t('model.friendship.error.already_exist'))
  end
end
