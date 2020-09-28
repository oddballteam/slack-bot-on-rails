# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  describe '.create_or_update_from_oauth' do
    subject { Team.create_or_update_from_oauth(oauth) }

    let(:access_token) { oauth['access_token'] }
    let(:bot_user_id) { oauth['bot_user_id'] }
    let(:slack_id) { oauth['team']['id'] }
    let(:team_name) { oauth['team']['name'] }
    let(:user_access_token) { oauth['authed_user']['access_token'] }
    let(:user_id) { oauth['authed_user']['id'] }
    let(:oauth) { FactoryBot.attributes_for(:oauth).with_indifferent_access }

    its(:access_token) { is_expected.to eq access_token }
    its(:bot_user_id) { is_expected.to eq bot_user_id }
    its(:slack_id) { is_expected.to eq slack_id }
    its(:name) { is_expected.to eq team_name }
    its(:user_id) { is_expected.to eq user_id }
    its(:user_access_token) { is_expected.to eq user_access_token }
    its(:valid?) { is_expected.to be true }

    context 'duplicate tokens' do
      let(:errors) do
        [
          'Access token has already been used',
          'Team is already registered'
        ]
      end

      before { Team.create_or_update_from_oauth(oauth) }

      its(:valid?) { is_expected.to be false }
      its(:errors) { is_expected.to match_array(errors) }
    end

    context 'reactivates and updates tokens' do
      context 'access token' do
        let!(:team) { FactoryBot.create(:team, :inactive, user_access_token: user_access_token, slack_id: slack_id) }

        its(:access_token) { is_expected.to eq access_token }
        its(:errors) { is_expected.to be_empty }
        its(:id) { is_expected.to eq team.id }
        its(:valid?) { is_expected.to be true }
      end

      context 'user token' do
        let!(:team) { FactoryBot.create(:team, :inactive, access_token: access_token, slack_id: slack_id) }

        its(:user_access_token) { is_expected.to eq user_access_token }
        its(:errors) { is_expected.to be_empty }
        its(:id) { is_expected.to eq team.id }
        its(:valid?) { is_expected.to be true }
      end

      context 'all tokens' do
        let!(:team) { FactoryBot.create(:team, :inactive, slack_id: slack_id) }

        its(:access_token) { is_expected.to eq access_token }
        its(:user_access_token) { is_expected.to eq user_access_token }
        its(:errors) { is_expected.to be_empty }
        its(:id) { is_expected.to eq team.id }
        its(:valid?) { is_expected.to be true }
      end
    end
  end

  describe '#slack_client' do
    subject { team.slack_client }
    let(:team) { FactoryBot.build(:team) }
    it { is_expected.to be_a Slack::Web::Client }
    its(:token) { is_expected.to eq team.access_token }
  end
end
