# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamsController, type: :request do
  subject { response }

  let(:team) { FactoryBot.build_stubbed(:team) }

  describe 'GET /teams' do
    before do
      allow(Team).to receive(:all) { [team] }
      get '/teams'
    end

    it { is_expected.to have_http_status(:ok) }
    its(:body) { is_expected.to eq [team].to_json }
  end

  describe 'POST /teams' do
    let(:client) { double('Slack::Web::Client') }
    let(:oauth) { FactoryBot.attributes_for(:oauth).with_indifferent_access }

    before do
      allow(Slack::Web::Client).to receive(:new) { client }
      allow(client).to receive(:oauth_access) { oauth }
      allow(Team).to receive(:create_or_update_from_oauth).with(oauth) { team }
    end

    context 'success' do
      before do
        get '/teams/create', params: { code: 'ABC123' }
      end

      it { is_expected.to have_http_status(:created) }
      its(:body) { is_expected.to eq team.to_json }
    end

    context 'errors' do
      let(:errors) { ['bad ideas'] }

      before do
        allow(team).to receive(:errors) { ['bad ideas'] }
        get '/teams/create', params: { code: 'ABC123' }
      end

      it { is_expected.to have_http_status(:unprocessable_entity) }
      its(:body) { is_expected.to eq errors.to_json }
    end
  end

  describe 'GET /teams/new' do
    before do
      get '/teams/new'
    end

    it { is_expected.to have_http_status(:ok) }
  end
end
