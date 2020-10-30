# frozen_string_literal: true

# mark tracked slack thread as resolved
class ResolveThreadJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 10

  def run(event_id:, options: nil)
    event = SlackEvent.find(event_id)
    slack_thread = SlackThread.find_or_initialize_by_event(event)

    SlackThread.transaction do
      slack_thread.update(ended_at: Time.zone.now)
      CloseIssueJob.enqueue(thread_id: slack_thread.id) if slack_thread.errors.empty?
      event.update(state: 'replied')
      # destroy the job when finished
      destroy
    end

    # post message in slack thread
    message = render('slack_thread/resolve.slack', slack_thread: slack_thread)
    slack_thread.post_ephemeral_reply(message, event.user)
  end
end
