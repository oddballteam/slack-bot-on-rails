# frozen_string_literal: true

RSpec.describe ResolveThreadJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:success) { true }
  let(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    allow(thread).to receive(:post_ephemeral_reply)
    allow(thread).to receive(:update) { success }
    ResolveThreadJob.run(event_id: event.id)
  end

  context 'save succeeds' do
    it 'replies "resolved"' do
      expect(thread).to have_received(:post_ephemeral_reply).with(/resolved/i, 'U061F7AUR')
    end
  end

  context 'save fails' do
    let(:success) { false }
    it 'replies "errors"' do
      expect(thread).to have_received(:post_ephemeral_reply).with(/errors/i, 'U061F7AUR')
    end
  end
end
