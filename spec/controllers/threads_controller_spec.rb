RSpec.describe ThreadsController do
  describe 'GET /' do
    context 'mime types' do
      let(:thread) { SlackThread.new }
      let(:threads) { [thread] }

      before { allow(SlackThread).to receive(:all) { threads } }

      context '.json' do
        it 'responds with JSON' do
          get :index, as: :json
          expect(response.body).to eq(threads.to_json)
        end
      end
    end

    context 'date queries' do
      let(:last_month) { 1.month.ago.to_date }
      let!(:last_months_threads) { [ SlackThread.create(started_at: last_month) ] }
      let(:this_month) { Date.today }
      let!(:this_months_threads) { [ SlackThread.create(started_at: this_month) ] }

      it 'responds with last month\'s threads' do
        get :index, params: { from: last_month.iso8601, to: this_month.iso8601 }, as: :json
        expect(response.body).to eq(last_months_threads.to_json)
      end
    end
  end

  describe 'GET /:id' do
    let(:thread) { SlackThread.new() }
    before { allow(SlackThread).to receive(:find).with('123') { thread } }

    it 'responds with HTML' do
      get :show, params: { id: 123 }, as: :json
      expect(response.body).to eq(thread.to_json)
    end
  end
end
