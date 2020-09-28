# frozen_string_literal: true

# reply in Slack thread w/ the categories for the current thread.
class ListThreadCategoriesJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 100

  def run(event_id:)
    message = 'An unexpected error occurred. :shrug:'
    event = SlackEvent.find(event_id)
    slack_thread = SlackThread.find_by(slack_ts: event.thread_ts)

    SlackThread.transaction do
      message = if slack_thread
                  "Categories: #{thread.category_list || 'None. _Yet_'}. 📚"
                else
                  'We are not tracking this thread. Tell us to track it.'
                end

      event.update(state: 'replied')
      # destroy the job when finished
      destroy
    end

    # post message in slack thread
    slack_thread.post_message(message)
  end
end
