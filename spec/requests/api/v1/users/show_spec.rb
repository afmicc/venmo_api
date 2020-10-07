require 'rails_helper'

describe 'GET /api/v1/users/:id', type: :request do
  subject(:get_user) { get api_v1_user_path(id) }

  context 'when the user exists' do
    let!(:user) { create(:user) }
    let(:id) { user.id }

    before { get_user }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'returns the new user info' do
      expect(response.parsed_body).to include_json(
        user:
        {
          id: id,
          email: user.email,
          name: user.name
        }
      )
    end
  end

  context 'when the user does not exist' do
    let(:id) { Faker::Number.number }

    before { get_user }

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
