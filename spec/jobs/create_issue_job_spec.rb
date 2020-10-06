# frozen_string_literal: true

# TODO: this should be converted to create a single issue, and run immediately after create thread
RSpec.describe CreateIssueJob do
  let(:issue) { FactoryBot.build(:github_issue) }
  let(:slack_thread) { FactoryBot.build_stubbed(:slack_thread) }

  before do
    allow(GithubInstallation).to receive(:last) { installation }
    allow(SlackThread).to receive(:find).with(slack_thread.id) { slack_thread }
    allow(slack_thread).to receive(:post_message)
    allow(installation).to receive(:create_issue) { issue }
    allow(slack_thread).to receive(:update) { true }
    CreateIssueJob.run(thread_id: slack_thread.id)
  end

  context 'before github installation' do
    subject(:installation) { FactoryBot.build(:github_installation, repository: '') }
    it { is_expected.not_to have_received(:create_issue).with(any_args) }
  end

  context 'after github installation' do
    subject(:installation) { FactoryBot.build(:github_installation) }
    it { is_expected.to have_received(:create_issue).with(title: "Slack thread ##{slack_thread.id}") }

    it 'posts the issue URL to slack' do
      expect(slack_thread).to have_received(:post_message).with(/github\.com/i)
    end

    it 'saves issue_url' do
      expect(slack_thread).to have_received(:update).with(issue_url: issue.html_url)
    end
  end
end
