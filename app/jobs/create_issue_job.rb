# frozen_string_literal: true

# - create github issue
#   - if there is no github auth yet, or if create issue fails, post an error to slack re: how to fix
# - state: ticketed
# - post update to Slack with link to github ticket
#   - hype how this process helps us to solve 100% of issues via documentation?
class CreateIssueJob < ApplicationJob
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
    issue = installation.create_issue(title: "Slack thread ##{slack_thread.id}")

    SlackThread.transaction do
      slack_thread.update(issue_url: issue.url) if issue&.url
      # destroy the job when finished
      destroy
    end
  end
end
