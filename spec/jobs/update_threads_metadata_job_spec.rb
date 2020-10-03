# frozen_string_literal: true

RSpec.describe UpdateThreadsMetadataJob do
  subject(:slack_thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackThread).to receive(:where).with(channel_name: nil) { [slack_thread] }
    allow(slack_thread).to receive(:update_metadata)
    UpdateThreadsMetadataJob.run
  end

  it { is_expected.to have_received(:update_metadata) }
end
