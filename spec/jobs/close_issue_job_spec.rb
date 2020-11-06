# frozen_string_literal: true

RSpec.describe CloseIssueJob do
  let(:slack_thread) { FactoryBot.build_stubbed(:slack_thread, :issue) }

  subject(:issue) { slack_thread.issue }

  before do
    allow(GithubInstallation).to receive(:last) { installation }
    allow(SlackThread).to receive(:find).with(slack_thread.id) { slack_thread }
    allow(slack_thread).to receive(:post_message)
    allow(issue).to receive(:close) { issue }
    CloseIssueJob.run(thread_id: slack_thread.id)
  end

  context 'github repository misconfigured' do
    let(:installation) { FactoryBot.build(:github_installation, repository: '') }
    it { is_expected.not_to have_received(:close) }
  end

  context 'github repository configured properly' do
    let(:installation) { FactoryBot.build(:github_installation) }
    it { is_expected.to have_received(:close) }
    it 'posts the issue URL to slack' do
      expect(slack_thread).to have_received(:post_message).with(/github\.com/i)
    end
  end
end
