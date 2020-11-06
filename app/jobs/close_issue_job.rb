# frozen_string_literal: true

# close github issue and post link to slack thread
class CloseIssueJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 10

  def run(thread_id:)
    installation = GithubInstallation.last
    # issues require a repository
    return unless installation&.repository&.present?

    slack_thread = SlackThread.find(thread_id)
    slack_thread.issue.close

    SlackThread.transaction do
      # destroy the job when finished
      destroy
    end

    # post link to issue in the slack thread
    message = render('slack_thread/issue_url.slack', flash: 'Issue closed:', slack_thread: slack_thread)
    slack_thread.post_message(message)
  end
end
