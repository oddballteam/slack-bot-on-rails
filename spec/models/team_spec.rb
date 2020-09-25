# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:access_token) { oauth['access_token'] }
  let(:bot_access_token) { oauth['bot']['bot_access_token'] }
  let(:team_id) { oauth['team_id'] }
  let(:team_name) { oauth['team_name'] }
  let(:oauth) { FactoryBot.attributes_for(:oauth).with_indifferent_access }

  describe '.from_oauth' do
    subject { Team.from_oauth(oauth) }

    its(:access_token) { is_expected.to eq access_token }
    its(:bot_access_token) { is_expected.to eq bot_access_token }
    its(:team_id) { is_expected.to eq team_id }
    its(:name) { is_expected.to eq team_name }
    its(:valid?) { is_expected.to be true }

    context 'duplicate tokens' do
      let(:errors) do
        [
          'Access token has already been used',
          'Bot access token has already been used',
          'Team is already registered'
        ]
      end

      before { Team.from_oauth(oauth) }

      its(:valid?) { is_expected.to be false }
      its(:errors) { is_expected.to match_array(errors) }
    end

    context 'reactivates and updates tokens' do
      context 'access token' do
        let!(:team) { FactoryBot.create(:team, :inactive, bot_access_token: bot_access_token, team_id: team_id) }

        its(:access_token) { is_expected.to eq access_token }
        its(:errors) { is_expected.to be_empty }
        its(:id) { is_expected.to eq team.id }
        its(:valid?) { is_expected.to be true }
      end

      context 'bot token' do
        let!(:team) { FactoryBot.create(:team, :inactive, access_token: access_token, team_id: team_id) }

        its(:bot_access_token) { is_expected.to eq bot_access_token }
        its(:errors) { is_expected.to be_empty }
        its(:id) { is_expected.to eq team.id }
        its(:valid?) { is_expected.to be true }
      end

      context 'all tokens' do
        let!(:team) { FactoryBot.create(:team, :inactive, team_id: team_id) }

        its(:access_token) { is_expected.to eq access_token }
        its(:bot_access_token) { is_expected.to eq bot_access_token }
        its(:errors) { is_expected.to be_empty }
        its(:id) { is_expected.to eq team.id }
        its(:valid?) { is_expected.to be true }
      end
    end
  end
end
