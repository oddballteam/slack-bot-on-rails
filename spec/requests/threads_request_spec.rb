# frozen_string_literal: true

RSpec.describe ThreadsController, type: :request do
  describe 'GET /threads' do
    context 'mime types' do
      let(:thread) { FactoryBot.build(:slack_thread, :user) }
      let(:threads) { [thread] }

      before { allow(SlackThread).to receive(:all) { threads } }

      it 'responds with HTML' do
        get '/threads', as: :html
        expect(response.body).to include('data-react-class="threads/List"')
      end

      it 'responds with JSON' do
        get '/threads', as: :json
        expect(response.body).to eq(threads.to_json)
      end
    end

    context 'date queries' do
      let(:last_month) { 1.month.ago.to_date }
      let!(:last_months_threads) { [FactoryBot.create(:slack_thread, :team, started_at: last_month)] }
      let(:this_month) { Time.zone.today }
      let!(:this_months_threads) { [FactoryBot.create(:slack_thread, :team, started_at: this_month)] }

      it 'responds with last month\'s threads' do
        get '/threads', params: {from: last_month.iso8601, to: this_month.iso8601}, as: :json
        expect(response.body).to eq(last_months_threads.to_json)
      end
    end
  end

  describe 'GET /threads/:id' do
    let(:thread) { SlackThread.new }
    before { allow(SlackThread).to receive(:find).with('123') { thread } }

    it 'responds with HTML' do
      get '/threads/123', as: :html
      expect(response.body).to include('data-react-class="threads/Edit"')
    end

    it 'responds with JSON' do
      get '/threads/123', as: :json
      expect(response.body).to eq(thread.to_json)
    end
  end
end
