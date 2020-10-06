# frozen_string_literal: true

RSpec.describe AddThreadLinkJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:success) { true }
  let(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    expect(thread).to receive(:save) { success }
    allow(thread).to receive(:post_ephemeral_reply)
    AddThreadLinkJob.run(event_id: event.id, options: 'https://www.test.com')
  end

  context 'save succeeds' do
    it 'replies "added"' do
      expect(thread).to have_received(:post_ephemeral_reply).with(/added/i, 'U061F7AUR')
    end
  end

  context 'save fails' do
    let(:success) { false }

    it 'replies "errors"' do
      expect(thread).to have_received(:post_ephemeral_reply).with(/errors/i, 'U061F7AUR')
    end
  end
end
