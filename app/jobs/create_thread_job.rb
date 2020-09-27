# frozen_string_literal: true

class CreateThreadJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 1

  def run(event_id:)
    # get add'l thread metadata from Slack API
    # - permalink
    # - thread creator
    # event = SlackEvent.find(event_id)
    # thread = SlackThread.find_or_create_by_event(slack_ts: event.ts)
    #
    # SlackThread.transaction do
    #   # Write any changes you'd like to the database.
    #   thread.save

    #   # It's best to destroy the job in the same transaction as any other
    #   # changes you make. Que will mark the job as destroyed for you after the
    #   # run method if you don't do it yourself, but if your job writes to the DB
    #   # but doesn't destroy the job in the same transaction, it's possible that
    #   # the job could be repeated in the event of a crash.
    #   destroy

    #   # If you'd rather leave the job record in the database to maintain a job
    #   # history, simply replace the `destroy` call with a `finish` call.
    # end

    # post message in slack thread
  end
end
