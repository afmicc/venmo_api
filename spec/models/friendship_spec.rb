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

require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe 'validations' do
    describe '.friendship_already_exists' do
      let!(:user) { create(:user) }
      let!(:friend) { create(:user) }

      subject(:create_user) { create(:friendship, user: user, friend: friend) }

      context 'when the friendship does not exist' do
        it 'creates a new friendship' do
          expect { create_user }.to change(Friendship, :count).by(1)
        end

        context 'when the params are inverted' do
          subject(:create_user) { create(:friendship, user: friend, friend: user) }

          it 'creates a new friendship' do
            expect { create_user }.to change(Friendship, :count).by(1)
          end
        end
      end

      context 'when the friendship exists' do
        let!(:friendship) { create(:friendship, user: user, friend: friend) }

        it 'raises a RecordInvalid error' do
          expect { create_user }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'raises an error message' do
          expect { create_user }.to raise_error(
            ActiveRecord::RecordInvalid,
            /The frienship already exists/
          )
        end

        context 'when the params are inverted' do
          subject(:create_user) { create(:friendship, user: friend, friend: user) }

          it 'raises a RecordInvalid error' do
            expect { create_user }.to raise_error(ActiveRecord::RecordInvalid)
          end

          it 'raises an error message' do
            expect { create_user }.to raise_error(
              ActiveRecord::RecordInvalid,
              /The frienship already exists/
            )
          end
        end
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:friend).class_name('User') }
  end

  describe '.friendship_of' do
    let!(:user) { create(:user) }
    let!(:friend_1) { create(:user) }
    let!(:friend_2) { create(:user) }
    let!(:no_friend) { create(:user) }
    let!(:user_friendships) do
      [
        create(:friendship, user: user, friend: friend_1),
        create(:friendship, user: friend_2, friend: user)
      ]
    end
    let!(:no_user_friendships) do
      [
        create(:friendship, user: no_friend, friend: friend_1),
        create(:friendship, user: friend_2, friend: no_friend)
      ]
    end

    subject { described_class.friendships_of(user) }

    it 'includes friendship between user and their friends' do
      expect(subject).to match_array(user_friendships)
    end

    it 'does not include friendship between their friends and another user' do
      expect(subject).not_to match_array(no_user_friendships)
    end

    context 'when provides an array of user‘s id' do
      let!(:user_2) { create(:user) }
      let!(:user_2_friendships) do
        [
          create(:friendship, user: user_2, friend: friend_1),
          create(:friendship, user: friend_2, friend: user_2)
        ]
      end

      subject { described_class.friendships_of([user.id, user_2.id]) }

      it 'includes friendship between users and their friends' do
        expect(subject).to match_array(user_friendships + user_2_friendships)
      end

      it 'does not include friendship between their friends and another user' do
        expect(subject).not_to match_array(no_user_friendships)
      end
    end
  end
end
