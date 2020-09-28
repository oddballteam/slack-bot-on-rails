# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :request do
  subject { response }

  describe 'POST /events' do
    # per https://api.slack.com/apps/A01AAGMMNHJ/event-subscriptions,
    # We'll send HTTP POST requests to this URL when events occur.
    # As soon as you enter a URL, we'll send a request with a challenge parameter,
    # and your endpoint must respond with the challenge value.
    #
    # per https://api.slack.com/events/url_verification,
    # The payload you'll receive is similar to this JSON:
    # {
    #   "token": "Jhj5dZrVaK7ZwHHjRyZWjbDl",
    #   "challenge": "3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P",
    #   "type": "url_verification"
    # }
    # Once you receive the event, verify the request's authenticity and then respond
    # with the challenge attribute value.
    # HTTP 200 OK
    # Content-type: application/json
    # {"challenge":"3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P"}
    context 'origin challenge & validation' do
      let(:challenge) { '3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P' }
      let(:params) do
        {
          'token' => 'Jhj5dZrVaK7ZwHHjRyZWjbDl',
          'challenge' => challenge,
          'type' => 'url_verification'
        }
      end
      let(:json) do
        { challenge: challenge }.to_json
      end

      before do
        post '/events', params: params
      end

      it { is_expected.to have_http_status(:ok) }
      its(:body) { is_expected.to eq json }
    end

    context 'app_mention' do
      let(:event) { FactoryBot.build(:slack_event, :app_mention) }

      before do
        post '/events', params: event.metadata
      end

      it { is_expected.to have_http_status(:created) }
    end

    # context 'errors' do
    #   before do
    #     post '/events'
    #   end

    #   it { is_expected.to have_http_status(:unprocessable_entity) }
    # end
  end
end
