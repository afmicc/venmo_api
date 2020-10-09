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

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it {
      is_expected.to have_many(:outgoing_friendships).class_name('Friendship')
                                                     .inverse_of(:user)
                                                     .dependent(:destroy)
    }
    it {
      is_expected.to have_many(:outgoing_friends).through(:outgoing_friendships)
                                                 .source(:friend)
    }
    it {
      is_expected.to have_many(:incoming_friendships).with_foreign_key('friend_id')
                                                     .class_name('Friendship')
                                                     .inverse_of(:friend)
                                                     .dependent(:destroy)
    }
    it {
      is_expected.to have_many(:incoming_friends).through(:incoming_friendships)
                                                 .source(:user)
    }
    it {
      is_expected.to have_many(:received_payments).class_name('Payment')
                                                  .dependent(:nullify)
                                                  .inverse_of(:receiver)
    }
    it {
      is_expected.to have_many(:sent_payments).class_name('Payment')
                                              .dependent(:nullify)
                                              .inverse_of(:sender)
    }
  end

  describe '#friends' do
    let!(:user) { create(:user) }
    let!(:friend) { create(:user) }
    let!(:friend_2) { create(:user) }
    let!(:no_friend) { create(:user) }
    let!(:friendships) do
      [
        create(:friendship, user: user, friend: friend),
        create(:friendship, user: friend_2, friend: user)
      ]
    end
    let!(:no_friendships) do
      [
        create(:friendship, user: friend, friend: no_friend),
        create(:friendship, user: no_friend, friend: friend_2)
      ]
    end

    subject { user.friends }

    it 'contains user friends user' do
      expect(subject).to contain_exactly(friend, friend_2)
    end

    it 'does not contain no friends users' do
      expect(subject).not_to contain_exactly(no_friend)
    end
  end
end
