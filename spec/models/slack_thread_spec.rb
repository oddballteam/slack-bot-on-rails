# frozen_string_literal: true

RSpec.describe SlackThread do
  let(:thread) { FactoryBot.build_stubbed(:slack_thread, :user) }

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
    let(:permalink) { 'https://example.com/' }
    let(:started_at) { Time.parse('2018-01-08 22:12:02 UTC') } # thread_ts as UTC date

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

    describe '#channel_id' do
      subject { thread.channel_id }
      it { is_expected.to eq(event.channel) }
    end

    describe '#team' do
      subject { thread.team }
      let!(:team) { FactoryBot.create(:team, slack_id: event.team) }
      its(:slack_id) { is_expected.to eq event.team }
    end
  end

  describe '#as_json' do
    subject { thread.as_json }
    it { is_expected.to include('reply_users_names', 'started_by_name') }
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
        channel: thread.channel_id,
        thread_ts: thread.slack_ts,
        text: message,
        user: 'DEF789'
      }
    end
    let(:message) { 'Halo Whirrled' }
    let(:thread) { FactoryBot.build_stubbed(:slack_thread, :team) }

    before do
      allow(thread.slack_client).to receive(:chat_postEphemeral)
      thread.post_message(message, 'DEF789')
    end

    it { is_expected.to have_received(:chat_postEphemeral).with(args) }
  end

  describe '#reply_users_names' do
    let(:thread) { FactoryBot.create(:slack_thread_with_reply_users, :team) }
    subject { thread.reply_users_names }
    it { is_expected.to eq 'Bobby Tables, Bobby Tables' }
  end

  describe '#started_by_name' do
    subject { thread.started_by_name }
    it { is_expected.to eq 'Bobby Tables' }
  end

  describe '#update_metadata' do
    subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :team) }
    let(:chat_permalink) { FactoryBot.build(:chat_permalink) }

    before do
      allow(thread.slack_client).to receive(:conversations_info) { conversations_info }
      allow(thread.slack_client).to receive(:chat_getPermalink) { chat_permalink }
      allow(thread).to receive(:save) { true }
    end

    context 'slack API success' do
      let(:conversations_info) { FactoryBot.build(:conversations_info) }

      before do
        thread.update_metadata
      end

      it { is_expected.to have_received(:save) }
      its(:slack_client) { is_expected.to have_received(:conversations_info).with(channel: thread.channel_id) }
      its(:slack_client) do
        is_expected.to have_received(:chat_getPermalink).with(channel: thread.channel_id, message_ts: thread.slack_ts)
      end
      its(:channel_name) { is_expected.to eq 'general' }
      its(:permalink) { is_expected.to eq 'https://ghostbusters.slack.com/archives/C1H9RESGA/p135854651500008' }
    end

    context 'slack API error: missing scope' do
      let(:conversations_info) { raise Slack::Web::Api::Errors::MissingScope, 'missing scope' }
      its(:update_metadata) { is_expected.to eq false }
    end
  end

  describe '#update_replies' do
    subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :team) }

    let(:args) do
      {
        channel: thread.channel_id,
        ts: thread.slack_ts,
        inclusive: true,
        limit: 1
      }
    end
    let(:reply) { conversations_replies.messages.first }
    let(:user) { FactoryBot.build_stubbed(:user, team: thread.team) }
    let(:reply_users) { FactoryBot.build_stubbed_list(:user, 2, team: thread.team) }

    before do
      allow(thread.slack_client).to receive(:conversations_replies) { conversations_replies }
      allow(thread).to receive(:save) { true }
    end

    context 'slack API success' do
      let(:conversations_replies) { FactoryBot.build(:conversations_replies) }
      before do
        allow(User).to receive(:find_or_create_by).with(
          slack_id: reply['user'], team: thread.team
        ) { user }
        allow(User).to receive(:find_or_create_by).with(
          slack_id: reply['reply_users'].first, team: thread.team
        ) { reply_users.first }
        allow(User).to receive(:find_or_create_by).with(
          slack_id: reply['reply_users'].last, team: thread.team
        ) { reply_users.last }
        thread.update_replies
      end
      it { is_expected.to have_received(:save) }
      its(:slack_client) { is_expected.to have_received(:conversations_replies).with(args) }
      its(:latest_reply_ts) { is_expected.to eq '1601259545.006300' }
      its(:reply_count) { is_expected.to eq 14 }
      its(:reply_users) { is_expected.to eq "#{reply_users.first.id}, #{reply_users.last.id}" }
      its(:reply_users_count) { is_expected.to eq 2 }
      its(:starter) { is_expected.to eq user }
    end

    context 'slack API error: missing scope' do
      let(:conversations_replies) { raise Slack::Web::Api::Errors::MissingScope, 'missing scope' }
      its(:update_replies) { is_expected.to eq false }
    end
  end

  describe '#slack_client' do
    subject { thread.slack_client }
    let(:thread) { FactoryBot.create(:slack_thread, :team) }
    it { is_expected.to eq thread.team.slack_client }
  end
end
