# frozen_string_literal: true

RSpec.describe UpdateIssueTitleJob do
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:installation) { FactoryBot.build(:github_installation, :access_token) }
  let(:slack_user) { 'U061F7AUR' }
  let(:title) { 'Swallowed a bug' }

  subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :issue) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    allow(GithubInstallation).to receive(:last) { installation }
    allow(thread.issue).to receive(:title=)
    allow(thread).to receive(:post_ephemeral_reply)
    UpdateIssueTitleJob.run(event_id: event.id, options: title)
  end

  it 'replies "updated"' do
    expect(thread).to have_received(:post_ephemeral_reply).with(/updated/i, slack_user)
  end

  it 'updates the issue title' do
    expect(thread.issue).to have_received(:title=).with(title)
  end
end
