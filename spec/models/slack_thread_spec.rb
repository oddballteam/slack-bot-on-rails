# frozen_string_literal: true

RSpec.describe SlackThread do
  subject(:thread) { SlackThread.find_or_create_by_event(event) }

  let(:event) { FactoryBot.create(:slack_event, :thread) }
  let(:client) { double('Client', web_client: MockSlackClient.new) }
  let(:permalink) { 'https://example.com/' }
  let(:started_at) { Time.parse('2018-01-08 22:12:02 UTC') } # thread_ts as UTC date

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

    let(:tracked_thread) { SlackThread.find_or_create_by_event(event) }

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
    let!(:team) { FactoryBot.create(:team, team_id: event.team) }
    it { is_expected.to eq(permalink) }
  end

  context 'date queries' do
    let(:last_month) { 1.month.ago.to_date }
    let(:last_months_threads) { [FactoryBot.create(:slack_thread, started_at: last_month)] }
    let(:this_month) { Date.today }
    let(:this_months_threads) { [FactoryBot.create(:slack_thread, started_at: this_month)] }
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

  # describe '#slack_last_ts' do
  #   subject { thread.slack_last_ts }
  #   let(:first_slack_ts) { '1482960137.003542' }
  #   let(:last_slack_ts) { '1482960137.003543' }

  #   # mock Slack web API responses
  #   let(:first_page) do
  #     double(
  #       'Messages Page 1',
  #       ok?: true,
  #       has_more?: has_more,
  #       messages: [double('First', ts: first_slack_ts)]
  #     )
  #   end
  #   let(:last_page) do
  #     double(
  #       'Messages Page 2',
  #       ok?: true,
  #       has_more?: false,
  #       messages: [double('Last', ts: last_slack_ts)]
  #     )
  #   end

  #   before do
  #     allow_any_instance_of(Slack::Web::Client).to receive(:conversations_replies).with(hash_including(
  #       oldest: nil, channel: thread.channel, ts: thread.slack_ts, inclusive: true
  #     )).and_return(first_page)
  #     allow_any_instance_of(Slack::Web::Client).to receive(:conversations_replies).with(hash_including(
  #       oldest: first_page.messages.first.ts, channel: thread.channel, ts: thread.slack_ts, inclusive: true
  #     )).and_return(last_page)
  #   end

  #   context 'one results page' do
  #     let(:has_more) { false }
  #     it { is_expected.to eq(first_page.messages) }
  #   end

  #   context 'multiple results pages' do
  #     let(:has_more) { true }
  #     it { is_expected.to eq(last_slack_ts) }
  #   end
  # end
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
