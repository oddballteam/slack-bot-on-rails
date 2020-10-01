# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#update_profile_details' do
    subject(:user) { FactoryBot.build(:user, :team) }

    before do
      allow(user).to receive(:save) { true }
      allow(user.slack_client).to receive(:users_profile_get) { slack_user_profile }
    end

    context 'slack API success' do
      let(:slack_user_profile) { FactoryBot.build(:slack_user_profile) }
      before { user.update_profile_details }
      it { is_expected.to have_received(:save) }
      its(:slack_client) { is_expected.to have_received(:users_profile_get).with(user: user.slack_id) }
      its(:display_name) { is_expected.to eq 'Bobby Tables' }
      its(:image_url) { is_expected.to eq 'https://www.test.com/image.jpg' }
      its(:real_name) { is_expected.to eq 'The Most Groovy Bobby Tables' }
    end

    context 'slack API error: missing scope' do
      let(:slack_user_profile) { raise Slack::Web::Api::Errors::MissingScope, 'missing scope' }
      its(:update_profile_details) { is_expected.to eq false }
    end
  end
end
