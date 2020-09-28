# frozen_string_literal: true

RSpec.describe SlackThread do
  let(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  context 'date range queries' do
    let(:last_month) { 1.month.ago.to_date }
    let(:last_months_threads) { [FactoryBot.create(:slack_thread, :team, started_at: last_month)] }
    let(:this_month) { Date.today }
    let(:this_months_threads) { [FactoryBot.create(:slack_thread, :team, started_at: this_month)] }
    let(:threads) { last_months_threads.concat(last_months_threads) }

    describe '.after(this_month)' do
      subject { SlackThread.after(this_month) }
      it { is_expected.to match_array(this_months_threads) }
    end

    describe '.before(this_month)' do
      subject { SlackThread.before(this_month) }
      it { is_expected.to match_array(last_months_threads) }
    end

    describe '.after(last_month).before(this_month)' do
      subject { SlackThread.after(last_month).before(this_month) }
      it { is_expected.to match_array(last_months_threads) }
    end
  end

  describe '.datetime_from_ts' do
    subject { SlackThread.datetime_from_ts(slack_ts: 123, default: yesterday) }
    let(:yesterday) { DateTime.yesterday }
    it { is_expected.to eq yesterday }
  end

  describe '.find_or_initialize_by_event' do
    subject(:thread) { SlackThread.find_or_initialize_by_event(event) }

    let(:event) { FactoryBot.create(:slack_event, :thread) }
    let(:client) { MockSlackClient.new }
    let(:permalink) { 'https://example.com/' }
    let(:started_at) { Time.parse('2018-01-08 22:12:02 UTC') } # thread_ts as UTC date
    # let(:started_by) {  }

    before do
      allow(Slack::Web::Client).to receive(:new) { client }
    end

    context 'an untracked thread' do
      describe '#started_at' do
        subject { thread.started_at }
        it { is_expected.to eq(started_at) }
      end

      describe '#slack_ts' do
        subject { thread.slack_ts }
        it { is_expected.to eq(event.thread_ts) }
      end
    end

    context 'an already tracked thread' do
      subject { thread }

      let(:tracked_thread) { SlackThread.find_or_initialize_by_event(event) }

      before do
        expect(SlackThread).to receive(:find_by).with(slack_ts: event.thread_ts).and_return(tracked_thread)
      end

      it { is_expected.to eq(tracked_thread) }
    end

    describe '#channel' do
      subject { thread.channel }
      it { is_expected.to eq(event.channel) }
    end

    describe '#permalink' do
      subject { thread.permalink }
      let!(:team) { FactoryBot.create(:team, slack_id: event.team) }
      it { is_expected.to eq(permalink) }
    end

    describe '#team' do
      subject { thread.team }
      let!(:team) { FactoryBot.create(:team, slack_id: event.team) }
      its(:slack_id) { is_expected.to eq event.team }
    end
  end

  describe '#formatted_link' do
    subject { thread.formatted_link }

    it { is_expected.to include "/threads/#{thread.id}" }

    context 'ENV var set' do
      before { allow(ENV).to receive(:[]).with('HEROKU_APP_NAME').and_return('dummy') }
      it { is_expected.to include 'dummy.herokuapp.com' }
    end

    context 'ENV var not set' do
      it { is_expected.to include 'localhost:3000' }
    end
  end

  describe '#post_message' do
    subject { thread.slack_client }

    let(:args) do
      {
        channel: thread.channel,
        thread_ts: thread.slack_ts,
        text: message
      }
    end
    let(:message) { 'Halo Whirrled' }
    let(:thread) { FactoryBot.build_stubbed(:slack_thread, :team) }

    before do
      allow(thread.slack_client).to receive(:chat_postMessage)
      thread.post_message(message)
    end

    it { is_expected.to have_received(:chat_postMessage).with(args) }
  end

  describe '#update_conversation_details' do
    subject { thread }

    let(:args) do
      {
        channel: thread.channel,
        ts: thread.slack_ts,
        inclusive: true,
        limit: 1
      }
    end
    let(:thread) { FactoryBot.build(:slack_thread, :team) }

    before do
      allow(thread.slack_client).to receive(:conversations_replies) { slack_replies }
    end

    context 'slack API success' do
      let(:slack_replies) { FactoryBot.build(:slack_reply) }
      before { thread.update_conversation_details }
      its(:slack_client) { is_expected.to have_received(:conversations_replies).with(args) }
      its(:latest_reply_ts) { is_expected.to eq '1601259545.006300' }
      its(:reply_count) { is_expected.to eq 14 }
      its(:reply_users) { is_expected.to eq 'U01A1628SLV, U0132PA923R' }
      its(:reply_users_count) { is_expected.to eq 2 }
      its(:started_by) { is_expected.to eq 'U0132PA923R' }
    end

    context 'slack API error: missing scope' do
      let(:slack_replies) { raise Slack::Web::Api::Errors::MissingScope, 'missing scope' }
      its(:update_conversation_details) { is_expected.to eq false }
    end
  end

  describe '#slack_client' do
    subject { thread.slack_client }
    let(:thread) { FactoryBot.create(:slack_thread, :team) }
    it { is_expected.to eq thread.team.slack_client }
  end
end

class MockSlackClient
  # mock client getPermalink
  def chat_getPermalink(channel:, message_ts:) # rubocop:disable Naming/MethodName
    self
  end

  # mock permalink
  def permalink
    'https://example.com/'
  end
end
