# frozen_string_literal: true

RSpec.describe RemoveThreadLinkJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }

  subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :links) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    expect(thread).to receive(:save)
    allow(thread).to receive(:post_ephemeral_reply)
    RemoveThreadLinkJob.run(event_id: event.id, options: 'https://www.test.com')
  end

  context 'save succeeds' do
    it { is_expected.to have_received(:post_ephemeral_reply).with(/removed/i, 'U061F7AUR') }
  end

  context 'save fails' do
    subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :links, :errors) }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/errors/i, 'U061F7AUR') }
  end
end
