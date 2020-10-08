require 'rails_helper'

describe 'POST /api/v1/users', type: :request do
  subject(:create_user) { post api_v1_users_path, params: params }

  context 'when params are right' do
    let(:params) { { user: attributes_for(:user) } }
    let(:last_user) { User.last }

    it 'returns a successful response' do
      create_user
      expect(response).to be_successful
    end

    it 'creates a new user' do
      expect { create_user }.to change(User, :count).by(1)
    end

    it 'returns the new user info' do
      create_user
      expect(response.parsed_body).to include_json(
        user:
        {
          id: last_user.id,
          email: params[:user][:email],
          name: params[:user][:name]
        }
      )
    end
  end

  context 'when missing params' do
    context 'when missing user' do
      let(:params) { attributes_for(:user) }

      it 'returns a failure response' do
        create_user
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a new user' do
        expect { create_user }.not_to change(User, :count)
      end

      it 'returns an error message' do
        create_user
        expect(response.parsed_body).to include_json(
          error: 'A required param is missing'
        )
      end
    end

    context 'when missing email' do
      let(:params) { { user: attributes_for(:user, email: nil) } }

      it 'returns a failure response' do
        create_user
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a new user' do
        expect { create_user }.not_to change(User, :count)
      end

      it 'returns an error message' do
        create_user
        expect(response.parsed_body).to include_json(
          errors:
          {
            email: contain_exactly("can't be blank")
          }
        )
      end
    end

    context 'when missing name' do
      let(:params) { { user: attributes_for(:user, name: nil) } }

      it 'returns a failure response' do
        create_user
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a new user' do
        expect { create_user }.not_to change(User, :count)
      end

      it 'returns an error message' do
        create_user
        expect(response.parsed_body).to include_json(
          errors:
          {
            name: contain_exactly("can't be blank")
          }
        )
      end
    end
  end

  context 'when already exists an user with the same email' do
    let(:email) { Faker::Internet.email }
    let!(:existing_user) { create(:user, email: email) }

    context 'when missing email' do
      let(:params) { { user: attributes_for(:user, email: email) } }

      it 'returns a failure response' do
        create_user
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a new user' do
        expect { create_user }.not_to change(User, :count)
      end

      it 'returns an error message' do
        create_user
        expect(response.parsed_body).to include_json(
          errors:
          {
            email: contain_exactly('has already been taken')
          }
        )
      end
    end
  end
end
