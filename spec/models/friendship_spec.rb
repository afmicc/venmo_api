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
end
