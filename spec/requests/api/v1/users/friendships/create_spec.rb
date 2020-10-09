require 'rails_helper'

describe 'POST /api/v1/users/:user_id/friendships', type: :request do
  let!(:user) { create(:user) }
  let!(:friend) { create(:user) }

  subject(:add_friend) { post api_v1_user_friendships_path(user_id), params: params }

  context 'when params are right' do
    let(:user_id) { user.id }
    let(:params) { { friend_id: friend.id } }

    context 'when the friendship does not exist' do
      it 'returns a successful response' do
        add_friend
        expect(response).to have_http_status(:no_content)
      end

      it 'creates a new friendship' do
        expect { add_friend }.to change(Friendship, :count).by(1)
      end

      context 'when the params are inverted' do
        let(:user_id) { friend.id }
        let(:params) { { friend_id: user.id } }

        it 'returns a successful response' do
          add_friend
          expect(response).to have_http_status(:no_content)
        end

        it 'creates a new friendship' do
          expect { add_friend }.to change(Friendship, :count).by(1)
        end
      end
    end

    context 'when the friendship exists' do
      let!(:friendship) { create(:friendship, user: user, friend: friend) }

      it 'returns a failure response' do
        add_friend
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a new friendship' do
        expect { add_friend }.not_to change(Friendship, :count)
      end

      it 'returns an error message' do
        add_friend
        expect(response.parsed_body).to include_json(
          errors:
          {
            base: ['The frienship already exists']
          }
        )
      end

      context 'when the params are inverted' do
        let(:user_id) { friend.id }
        let(:params) { { friend_id: user.id } }

        it 'returns a failure response' do
          add_friend
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a new friendship' do
          expect { add_friend }.not_to change(Friendship, :count)
        end

        it 'returns an error message' do
          add_friend
          expect(response.parsed_body).to include_json(
            errors:
            {
              base: ['The frienship already exists']
            }
          )
        end
      end
    end
  end

  context 'when missing params' do
    context 'when missing friend id' do
      let(:user_id) { user.id }
      let(:params) { {} }

      it 'returns a failure response' do
        add_friend
        expect(response).to have_http_status(:not_found)
      end

      it 'does not create a new friendship' do
        expect { add_friend }.not_to change(Friendship, :count)
      end

      it 'returns an error message' do
        add_friend
        expect(response.parsed_body).to include_json(
          error: "Couldn't find the record"
        )
      end
    end
  end

  context 'when users do not exist' do
    let(:user_id) { user.id }
    let(:params) { { friend_id: friend.id } }

    context 'when friend does not exist' do
      let(:params) { { friend_id: Faker::Number.number } }

      before { add_friend }

      it 'returns a failure response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(response.parsed_body).to include_json(
          error: "Couldn't find the record"
        )
      end
    end

    context 'when user does not exist' do
      let(:user_id) { Faker::Number.number }

      before { add_friend }

      it 'returns a failure response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        expect(response.parsed_body).to include_json(
          error: "Couldn't find the record"
        )
      end
    end
  end
end
