# frozen_string_literal: true

require 'rails_helper'

# record events from the Github Events API, for future processing
RSpec.describe GithubEventsController, type: :request do
  let(:path) { '/github_events' }
  subject { response }

  describe 'POST /github_events' do
    context 'installation' do
      let(:attrs) { FactoryBot.attributes_for(:github_event, :installation) }
      let!(:installation) { FactoryBot.build(:github_installation) }

      before do
        expect(GithubInstallation).to receive(:new).with(
          hash_including(github_id: attrs[:metadata]['installation']['id'])
        ) { installation }
        expect(installation).to receive(:save) { success }
        post path, params: attrs[:metadata]
      end

      context 'expected webhook' do
        let(:success) { true }
        it { is_expected.to have_http_status(:created) }
      end

      context 'unexpected webhook' do
        let(:success) { false }
        it { is_expected.to have_http_status(:ok) }
      end
    end

    # let(:attrs) { FactoryBot.attributes_for(:github_event, :installation) }
    # let!(:event) { GithubEvent.new(metadata: attrs[:metadata]) }
    # let(:success) { true }

    # before do
    #   expect(GithubEvent).to receive(:new).with(hash_including(:metadata)) { event }
    #   expect(event).to receive(:save) { success }
    #   allow(event).to receive(:enqueue_job)
    #   post '/github_events', params: attrs[:metadata]
    # end

    # context 'other events' do
    #   it { is_expected.to have_http_status(:created) }
    #   it 'enqueued the job' do
    #     expect(event).to have_received(:enqueue_job)
    #   end
    # end

    # context 'bad data' do
    #   let(:success) { false }
    #   it { is_expected.to have_http_status(:ok) }
    # end
  end
end
