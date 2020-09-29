# frozen_string_literal: true

RSpec.describe ResolveThreadJob do
  let(:persisted) { false }
  let(:success) { true }
  let(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackThread).to receive(:find).with(thread.id) { thread }
    allow(thread).to receive(:post_message)
    allow(thread).to receive(:update) { success }
    ResolveThreadJob.run(thread_id: thread.id)
  end

  context 'save succeeds' do
    it 'replies "resolved"' do
      expect(thread).to have_received(:post_message).with(/resolved/i)
    end
  end

  context 'save fails' do
    let(:success) { false }
    it 'replies "errors"' do
      expect(thread).to have_received(:post_message).with(/errors/i)
    end
  end
end
