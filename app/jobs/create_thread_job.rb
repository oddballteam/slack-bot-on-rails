# frozen_string_literal: true

# create tracked slack threads from events
class CreateThreadJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 10

  def run(event_id:, options: nil)
    event = SlackEvent.find(event_id)
    flash = ''
    slack_thread = SlackThread.find_or_initialize_by_event(event)

    SlackThread.transaction do
      flash = if slack_thread.persisted?
                'This thread is already being tracked'
              else
                CreateIssueJob.enqueue(thread_id: slack_thread.id) if slack_thread.save
                'Now tracking'
              end

      event.update(state: 'replied')
      # destroy the job when finished
      destroy
    end

    # post reply to slack user
    message = render('slack_thread/track.slack', flash: flash, slack_thread: slack_thread)
    slack_thread.post_ephemeral_reply(message, event.user)
    # post help to slack user
    help = render('slack_thread/help.slack')
    slack_thread.post_ephemeral_reply(help, event.user)
  end
end
