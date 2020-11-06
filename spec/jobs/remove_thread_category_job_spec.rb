# frozen_string_literal: true

RSpec.describe RemoveThreadCategoryJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:installation) { FactoryBot.build(:github_installation, :access_token) }
  let(:issue) { thread.issue }

  subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :categories, :issue) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    expect(thread).to receive(:save)
    allow(GithubInstallation).to receive(:last) { installation }
    allow(issue).to receive(:labels=) { issue }
    allow(thread).to receive(:post_ephemeral_reply)
    RemoveThreadCategoryJob.run(event_id: event.id, options: 'one')
  end

  context 'save succeeds' do
    let(:labels) { thread.category_list }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/removed/i, 'U061F7AUR') }
    it 'updates the issue label(s)' do
      expect(issue).to have_received(:labels=).with(labels)
    end
  end

  context 'save fails' do
    subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :categories, :issue, :errors) }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/errors/i, 'U061F7AUR') }
  end
end
