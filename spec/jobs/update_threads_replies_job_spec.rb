# frozen_string_literal: true

RSpec.describe UpdateThreadsRepliesJob do
  subject(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackThread).to receive(:where).with('updated_at > ?', 7.days.ago.to_date) { [thread] }
    allow(thread).to receive(:update_replies)
    UpdateThreadsRepliesJob.run
  end

  it { is_expected.to have_received(:update_replies) }
end
