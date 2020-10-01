# frozen_string_literal: true

RSpec.describe CreateThreadJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:persisted) { false }
  let(:success) { true }
  let(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    allow(thread).to receive(:post_message)
    allow(thread).to receive(:persisted?).and_return(persisted)
    allow(thread).to receive(:save) { success }
    CreateThreadJob.run(event_id: event.id)
  end

  context 'already tracked' do
    let(:persisted) { true }
    it 'replies "already tracked"' do
      expect(thread).to have_received(:post_message).with(/already being tracked/i, 'U061F7AUR')
    end
  end

  context 'save succeeds' do
    it 'replies "now tracking"' do
      expect(thread).to have_received(:post_message).with(/now tracking/i, 'U061F7AUR')
    end
  end

  context 'save fails' do
    let(:success) { false }
    it 'replies "errors"' do
      expect(thread).to have_received(:post_message).with(/errors/i, 'U061F7AUR')
    end
  end
end
