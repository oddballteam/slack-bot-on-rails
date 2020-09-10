describe SlackThread do
  subject(:thread) { SlackThread.from_command(client: client, data: data) }

  let(:client) { double('Client', web_client: MockSlackClient.new) }
  let(:data) do
    double(
      'data',
      channel: 'ABCDEF0123456789',
      thread_ts: '1599245993.010500',
      ts: '1599247956.016900'
    )
  end
  let(:started_at) { Time.parse("2020-09-04 18:59:53 UTC") } # thread_ts as UTC date
  let(:permalink) { 'https://example.com/' }

  context 'a new thread' do
    let(:started_at) { Time.parse("2020-09-04 19:32:36 UTC") } # ts as UTC date

    before { expect(data).to receive(:thread_ts).and_return(nil) }

    describe '#started_at' do
      subject { thread.started_at }
      it { is_expected.to eq(started_at) }
    end

    describe '#slack_ts' do
      subject { thread.slack_ts }
      it { is_expected.to eq(data.ts) }
    end
  end

  context 'an existing thread' do
    describe '#started_at' do
      subject { thread.started_at }
      it { is_expected.to eq(started_at) }
    end

    describe '#slack_ts' do
      subject { thread.slack_ts }
      it { is_expected.to eq(data.thread_ts) }
    end
  end

  describe '#channel' do
    subject { thread.channel }
    it { is_expected.to eq(data.channel) }
  end

  describe '#permalink' do
    subject { thread.permalink }
    it { is_expected.to eq(permalink) }
  end

  describe '#now_tracking' do
    subject { thread.now_tracking }
    it { is_expected.to include(permalink) }
    it { is_expected.to include(I18n.l(started_at, format: :long)) }
  end
end

class MockSlackClient
  def chat_getPermalink(channel:, message_ts:)
    self
  end

  def permalink
    'https://example.com/'
  end
end
