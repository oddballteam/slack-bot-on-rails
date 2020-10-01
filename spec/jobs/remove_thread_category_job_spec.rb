# frozen_string_literal: true

RSpec.describe RemoveThreadCategoryJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:success) { true }
  let(:thread) { FactoryBot.build_stubbed(:slack_thread, :categories) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    expect(thread).to receive(:save) { success }
    allow(thread).to receive(:post_message)
    RemoveThreadCategoryJob.run(event_id: event.id, options: 'one')
  end

  context 'save succeeds' do
    it 'replies "removed"' do
      expect(thread).to have_received(:post_message).with(/removed/i, 'U061F7AUR')
    end
  end

  context 'save fails' do
    let(:success) { false }
    it 'replies "errors"' do
      expect(thread).to have_received(:post_message).with(/errors/i, 'U061F7AUR')
    end
  end
end
