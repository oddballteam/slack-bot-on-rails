RSpec.describe ThreadsController do
  describe 'GET /' do
    context 'mime types' do
      let(:thread) { SlackThread.new }
      let(:threads) { [thread] }

      before do
        allow(SlackThread).to receive(:all) { threads }
      end

      context '.html' do
        it 'responds with HTML' do
          get :index, as: :html
          expect(response).to render_template('index')
        end
      end

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
end
