require 'rails_helper'

describe 'POST /api/v1/users/:user_id/payments', type: :request do
  let!(:user) { create(:user) }
  let!(:friend) { create(:user) }

  subject(:send_payment) { post api_v1_user_payments_path(user_id), params: params }

  context 'when params are right' do
    let(:user_id) { user.id }
    let(:friend_id) { friend.id }
    let(:amount) { Faker::Number.between(from: 0.1, to: 999.99).round(2) }
    let(:params) do
      {
        payment: attributes_for(:payment, amount: amount).merge(friend_id: friend_id)
      }
    end
    let(:initial_user_balance) { amount * 2 }
    let(:initial_friend_balance) { 0 }

    before do
      user.account.update!(balance: initial_user_balance)
      friend.account.update!(balance: initial_friend_balance)
    end

    context 'when the friendship exists' do
      let!(:friendship) { create(:friendship, user: user, friend: friend) }

      it 'returns a successful response' do
        send_payment
        expect(response).to have_http_status(:no_content)
      end

      it 'creates a new payment' do
        expect { send_payment }.to change(Payment, :count).by(1)
      end

      it 'matches payment attributes' do
        send_payment
        expect(Payment.last.to_json).to include_json(
          sender_id: user.id,
          receiver_id: friend.id,
          sender_email: user.email,
          receiver_email: friend.email,
          amount: params[:payment][:amount],
          description: params[:payment][:description]
        )
      end

      it 'creates a new event' do
        expect { send_payment }.to change(Event, :count).by(1)
      end

      it 'matches event attributes' do
        send_payment
        event = Event.last
        expect(event.to_json).to include_json(
          user_id: user.id,
          content: "#{user.name} paid #{friend.name} on"\
                   " #{event.created_at.strftime('%d %b %H:%M')} " \
                   "- #{params[:payment][:description]}"
        )
      end

      it 'decreases user account balane' do
        expect { send_payment }.to change { user.account.reload.balance }.by(-amount)
      end

      it 'increases friend account balane' do
        expect { send_payment }.to change { friend.account.reload.balance }.by(amount)
      end

      context 'when the params are inverted' do
        let(:user_id) { friend.id }
        let(:friend_id) { user.id }

        before do
          friend.account.update!(balance: initial_user_balance)
          user.account.update!(balance: initial_friend_balance)
        end

        it 'returns a successful response' do
          send_payment
          expect(response).to have_http_status(:no_content)
        end

        it 'creates a new payment' do
          expect { send_payment }.to change(Payment, :count).by(1)
        end

        it 'matches payment attributes' do
          send_payment
          expect(Payment.last.to_json).to include_json(
            sender_id: friend.id,
            receiver_id: user.id,
            sender_email: friend.email,
            receiver_email: user.email,
            amount: params[:payment][:amount],
            description: params[:payment][:description]
          )
        end

        it 'creates a new event' do
          expect { send_payment }.to change(Event, :count).by(1)
        end

        it 'matches event attributes' do
          send_payment
          event = Event.last
          expect(event.to_json).to include_json(
            user_id: friend.id,
            content: "#{friend.name} paid #{user.name} on"\
                     " #{event.created_at.strftime('%d %b %H:%M')} " \
                     "- #{params[:payment][:description]}"
          )
        end

        it 'decreases friend account balane' do
          expect { send_payment }.to change { friend.account.reload.balance }.by(-amount)
        end

        it 'increases user account balane' do
          expect { send_payment }.to change { user.account.reload.balance }.by(amount)
        end
      end
    end

    context 'when the friendship does not exist' do
      it 'returns a failure response' do
        send_payment
        expect(response).to have_http_status(:bad_request)
      end

      it 'does not create a new payment' do
        expect { send_payment }.not_to change(Payment, :count)
      end

      it 'returns an error message' do
        send_payment
        expect(response.parsed_body).to include_json(
          error: 'Something went wrong',
          detail: 'You must be friend to send payments'
        )
      end

      it 'does not create a new event' do
        expect { send_payment }.not_to change(Event, :count)
      end
    end
  end

  context 'when some params are not right' do
    let(:user_id) { user.id }
    let(:friend_id) { friend.id }
    let(:params) { { payment: attributes_for(:payment).merge(friend_id: friend_id) } }

    context 'when missing payment' do
      let(:params) { attributes_for(:payment) }

      it 'returns a failure response' do
        send_payment
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a new payment' do
        expect { send_payment }.not_to change(Payment, :count)
      end

      it 'returns an error message' do
        send_payment
        expect(response.parsed_body).to include_json(
          error: 'A required param is missing'
        )
      end

      it 'does not create a new event' do
        expect { send_payment }.not_to change(Event, :count)
      end
    end

    context 'when missing friend id' do
      let(:friend_id) { nil }

      it 'returns a failure response' do
        send_payment
        expect(response).to have_http_status(:not_found)
      end

      it 'does not create a new payment' do
        expect { send_payment }.not_to change(Payment, :count)
      end

      it 'returns an error message' do
        send_payment
        expect(response.parsed_body).to include_json(
          error: "Couldn't find the record"
        )
      end

      it 'does not create a new event' do
        expect { send_payment }.not_to change(Event, :count)
      end
    end

    context 'when amount is not right' do
      let!(:friendship) { create(:friendship, user: user, friend: friend) }
      let(:params) do
        {
          payment: attributes_for(:payment, amount: amount).merge(friend_id: friend_id)
        }
      end

      context 'when missing amount' do
        let(:amount) { nil }

        it 'returns a failure response' do
          send_payment
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a new payment' do
          expect { send_payment }.not_to change(Payment, :count)
        end

        it 'returns an error message' do
          send_payment
          expect(response.parsed_body).to include_json(
            errors:
            {
              amount: include('must be greater than 0')
            }
          )
        end

        it 'does not create a new event' do
          expect { send_payment }.not_to change(Event, :count)
        end
      end

      context 'when amount is less or equal than 0' do
        let(:amount) { 0 }

        it 'returns a failure response' do
          send_payment
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a new payment' do
          expect { send_payment }.not_to change(Payment, :count)
        end

        it 'returns an error message' do
          send_payment
          expect(response.parsed_body).to include_json(
            errors:
            {
              amount: contain_exactly('must be greater than 0')
            }
          )
        end

        it 'does not create a new event' do
          expect { send_payment }.not_to change(Event, :count)
        end
      end

      context 'when amount is greater or equal than 1000' do
        let(:amount) { 1_000 }

        it 'returns a failure response' do
          send_payment
          expect(response).to have_http_status(:bad_request)
        end

        it 'does not create a new payment' do
          expect { send_payment }.not_to change(Payment, :count)
        end

        it 'returns an error message' do
          send_payment
          expect(response.parsed_body).to include_json(
            errors:
            {
              amount: contain_exactly('must be less than 1000')
            }
          )
        end

        it 'does not create a new event' do
          expect { send_payment }.not_to change(Event, :count)
        end
      end
    end

    context 'when missing description' do
      let!(:friendship) { create(:friendship, user: user, friend: friend) }
      let(:params) do
        {
          payment: attributes_for(:payment, description: nil).merge(friend_id: friend_id)
        }
      end

      it 'returns a successful response' do
        send_payment
        expect(response).to have_http_status(:no_content)
      end

      it 'creates a new payment' do
        expect { send_payment }.to change(Payment, :count).by(1)
      end

      it 'creates a new event' do
        expect { send_payment }.to change(Event, :count).by(1)
      end
    end
  end
end
