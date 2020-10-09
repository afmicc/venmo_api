require 'rails_helper'

describe 'GET /api/v1/users/:id/feed', type: :request do
  let!(:user) { create(:user) }
  let!(:first_level_friend) { create(:user) }
  let!(:second_level_friend) { create(:user) }
  let!(:no_friend) { create(:user) }
  let!(:first_level_friendship) do
    create(:friendship, user: user, friend: first_level_friend)
  end
  let!(:second_level_friendship) do
    create(:friendship, user: first_level_friend, friend: second_level_friend)
  end
  let!(:strange_friendship) do
    create(:friendship, user: second_level_friend, friend: no_friend)
  end
  let(:params) { {} }

  subject(:get_feed) { get feed_api_v1_user_path(user.id), params: params }

  context 'when only exists user events' do
    let!(:events) do
      [
        create(:event, user: user, created_at: Time.zone.today),
        create(:event, user: user, created_at: 1.day.ago),
        create(:event, user: user, created_at: 2.days.ago),
        create(:event, user: user, created_at: 3.days.ago)
      ]
    end

    it 'returns a successful response' do
      get_feed
      expect(response).to be_successful
    end

    it 'returns events info ordered by creation date descending' do
      get_feed
      expect(response.parsed_body).to include_json(
        events: events.map do |event|
          {
            content: event.content,
            created_at: event.created_at.iso8601(3)
          }
        end
      )
    end

    it 'returns pagination info' do
      get_feed
      expect(response.parsed_body).to include_json(
        pagy: {
          count: events.size,
          page: 1,
          items: events.size,
          pages: 1
        }
      )
    end
  end

  context 'when exists first level friend and user events' do
    let!(:events) do
      [
        create(:event, user: user, created_at: Time.zone.today),
        create(:event, user: first_level_friend, created_at: 1.day.ago),
        create(:event, user: user, created_at: 2.days.ago),
        create(:event, user: first_level_friend, created_at: 3.days.ago)
      ]
    end

    it 'returns a successful response' do
      get_feed
      expect(response).to be_successful
    end

    it 'returns events info ordered by creation date descending' do
      get_feed
      expect(response.parsed_body).to include_json(
        events: events.map do |event|
          {
            content: event.content,
            created_at: event.created_at.iso8601(3)
          }
        end
      )
    end
  end

  context 'when exists first and second level friend and user events' do
    let!(:events) do
      [
        create(:event, user: first_level_friend, created_at: Time.zone.today),
        create(:event, user: user, created_at: 1.day.ago),
        create(:event, user: second_level_friend, created_at: 2.days.ago),
        create(:event, user: second_level_friend, created_at: 3.days.ago),
        create(:event, user: user, created_at: 4.days.ago),
        create(:event, user: first_level_friend, created_at: 5.days.ago)
      ]
    end

    it 'returns a successful response' do
      get_feed
      expect(response).to be_successful
    end

    it 'returns events info ordered by creation date descending' do
      get_feed
      expect(response.parsed_body).to include_json(
        events: events.map do |event|
          {
            content: event.content,
            created_at: event.created_at.iso8601(3)
          }
        end
      )
    end
  end

  context 'when exists friends, user and no friend events' do
    let!(:events) do
      [
        create(:event, user: first_level_friend, created_at: Time.zone.today),
        create(:event, user: user, created_at: 1.day.ago),
        create(:event, user: second_level_friend, created_at: 2.days.ago),
        create(:event, user: second_level_friend, created_at: 3.days.ago),
        create(:event, user: user, created_at: 4.days.ago),
        create(:event, user: first_level_friend, created_at: 5.days.ago)
      ]
    end
    let!(:hidden_event) { create_list(:event, 2, user: no_friend) }

    it 'returns a successful response' do
      get_feed
      expect(response).to be_successful
    end

    it 'returns only friend‘s events info ordered by creation date descending' do
      get_feed
      expect(response.parsed_body).to include_json(
        events: events.map do |event|
          {
            content: event.content,
            created_at: event.created_at.iso8601(3)
          }
        end
      )
    end

    it 'does not returns no-friend‘s events info' do
      get_feed
      expect(response.parsed_body).not_to include_json(
        events: hidden_event.map do |event|
          {
            content: event.content,
            created_at: event.created_at.iso8601(3)
          }
        end
      )
    end
  end

  context 'when there are more than 10 events' do
    let(:event_count) { 15 }
    let!(:events) { create_list(:event, event_count, :with_fake_created_at, user: user) }

    it 'returns a successful response' do
      get_feed
      expect(response).to be_successful
    end

    it 'returns first 10 events info ordered by creation date descending' do
      get_feed
      expect(response.parsed_body).to include_json(
        events: events.sort_by { |event| -event.created_at.to_i }
                      .first(10)
                      .map do |event|
                        {
                          content: event.content,
                          created_at: event.created_at.iso8601(3)
                        }
                      end
      )
    end

    it 'returns pagination info' do
      get_feed
      expect(response.parsed_body).to include_json(
        pagy: {
          count: event_count,
          page: 1,
          items: 10,
          pages: 2
        }
      )
    end

    context 'when sets the page param' do
      let(:params) { { page: 2 } }

      it 'returns a successful response' do
        get_feed
        expect(response).to be_successful
      end

      it 'returns last 5 events info ordered by creation date descending' do
        get_feed
        expect(response.parsed_body).to include_json(
          events: events.sort_by { |event| -event.created_at.to_i }
                        .last(5)
                        .map do |event|
                          {
                            content: event.content,
                            created_at: event.created_at.iso8601(3)
                          }
                        end
        )
      end

      it 'returns pagination info' do
        get_feed
        expect(response.parsed_body).to include_json(
          pagy: {
            count: event_count,
            page: 2,
            items: 5,
            pages: 2
          }
        )
      end
    end
  end
end
