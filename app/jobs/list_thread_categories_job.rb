# frozen_string_literal: true

# reply in Slack thread w/ the categories for the current thread.
class ListThreadCategoriesJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 100

  def run(event_id:, options: nil)
    event = SlackEvent.find(event_id)
    slack_thread = SlackThread.find_or_initialize_by(slack_ts: event.thread_ts)

    SlackEvent.transaction do
      event.update(state: 'replied')
      # destroy the job when finished
      destroy
    end

    # post message in slack thread
    message = render('slack_thread/labels.slack', flash: '', slack_thread: slack_thread)
    slack_thread.post_ephemeral_reply(message, event.user)
  end
end
