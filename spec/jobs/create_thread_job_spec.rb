# frozen_string_literal: true

RSpec.describe CreateThreadJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:issues_created) { 0 }
  let(:persisted) { false }
  let(:success) { true }

  subject(:thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    allow(thread).to receive(:post_ephemeral_reply).twice
    allow(thread).to receive(:persisted?).and_return(persisted)
    allow(thread).to receive(:save) { success }
    expect(CreateIssueJob).to receive(:enqueue).with(thread_id: thread.id).exactly(issues_created).times
    CreateThreadJob.run(event_id: event.id)
  end

  context 'already tracked' do
    let(:persisted) { true }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/already being tracked/i, 'U061F7AUR') }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/Help/i, 'U061F7AUR') }
  end

  context 'save succeeds' do
    let(:issues_created) { 1 }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/now tracking/i, 'U061F7AUR') }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/Help/i, 'U061F7AUR') }
    it { is_expected.to have_received(:save) }
  end

  context 'save fails' do
    let(:success) { false }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/errors/i, 'U061F7AUR') }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/Help/i, 'U061F7AUR') }
  end
end
