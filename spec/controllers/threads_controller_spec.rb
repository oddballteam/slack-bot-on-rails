RSpec.describe ThreadsController do
  describe 'GET /' do
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
end
