# frozen_string_literal: true

# add the given link to the current thread and
# reply in Slack thread w/ the updated link list.
class UpdateIssueTitleJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 100

  def run(event_id:, options:)
    event = SlackEvent.find(event_id)
    slack_thread = SlackThread.find_or_initialize_by_event(event)

    SlackEvent.transaction do
      slack_thread.issue.title = options
      event.update(state: 'replied')
      # destroy the job when finished
      destroy
    end

    # post link to issue in the slack thread
    message = render('slack_thread/issue_url.slack', flash: 'Issue title updated:', slack_thread: slack_thread)
    slack_thread.post_ephemeral_reply(message, event.user)
  end
end
