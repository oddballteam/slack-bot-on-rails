# frozen_string_literal: true

RSpec.describe AddThreadLinkJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:installation) { FactoryBot.build(:github_installation, :access_token) }

  subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :links, :issue) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    expect(thread).to receive(:save)
    allow(GithubInstallation).to receive(:last) { installation }
    allow(installation).to receive(:link_issue)
    allow(thread).to receive(:post_ephemeral_reply)
    AddThreadLinkJob.run(event_id: event.id, options: 'https://www.test.com')
  end

  context 'save succeeds' do
    let(:links) { thread.link_list }

    it 'replies "added"' do
      expect(thread).to have_received(:post_ephemeral_reply).with(/added/i, 'U061F7AUR')
    end

    it 'updates the issue link(s)' do
      expect(installation).to have_received(:link_issue).with(thread)
    end
  end

  context 'save fails' do
    subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :links, :issue, :errors) }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/errors/i, 'U061F7AUR') }
  end
end
