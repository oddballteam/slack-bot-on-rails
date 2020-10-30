# frozen_string_literal: true

RSpec.describe AddThreadCategoryJob do
  let(:errors) { [] }
  let(:event) { FactoryBot.build_stubbed(:slack_event) }
  let(:installation) { FactoryBot.build(:github_installation, :access_token) }
  let(:issue) { FactoryBot.build(:github_issue) }

  subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :categories, :issue) }

  before do
    expect(SlackEvent).to receive(:find).with(event.id) { event }
    expect(event).to receive(:update).with(state: 'replied')
    expect(SlackThread).to receive(:find_or_initialize_by_event).with(event) { thread }
    expect(thread).to receive(:save)
    allow(GithubInstallation).to receive(:last) { installation }
    allow(installation).to receive(:label_issue) { issue }
    allow(thread).to receive(:post_ephemeral_reply)
    AddThreadCategoryJob.run(event_id: event.id, options: 'cheese')
  end

  context 'save succeeds' do
    let(:labels) { thread.category_list }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/added/i, 'U061F7AUR') }
    it 'updates the issue label(s)' do
      expect(installation).to have_received(:label_issue).with(issue_number: thread.issue_number, labels: labels)
    end
  end

  context 'save fails' do
    subject(:thread) { FactoryBot.build_stubbed(:slack_thread, :categories, :issue, :errors) }
    it { is_expected.to have_received(:post_ephemeral_reply).with(/errors/i, 'U061F7AUR') }
  end
end
