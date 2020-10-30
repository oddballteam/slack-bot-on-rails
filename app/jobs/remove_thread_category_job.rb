# frozen_string_literal: true

# remove the named category from the current thread and
# reply in Slack thread w/ the updated category list.
class RemoveThreadCategoryJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 100

  def run(event_id:, options:)
    event = SlackEvent.find(event_id)
    slack_thread = SlackThread.find_or_initialize_by_event(event)

    SlackThread.transaction do
      slack_thread.category_list.remove(options)
      slack_thread.save
      event.update(state: 'replied')
      # destroy the job when finished
      destroy
    end

    # update issue labels
    installation = GithubInstallation.last
    if installation&.repository&.present?
      installation.label_issue(issue_number: slack_thread.issue_number, labels: slack_thread.category_list)
    end

    # post message in slack thread
    message = render('slack_thread/labels.slack', flash: "#{options} removed.", slack_thread: slack_thread)
    slack_thread.post_ephemeral_reply(message, event.user)
  end
end
