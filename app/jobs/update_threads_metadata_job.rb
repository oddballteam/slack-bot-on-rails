# frozen_string_literal: true

# update all recent threads with metadata from the Slack API
class UpdateThreadsMetadataJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 100

  def run
    slack_threads = SlackThread.where(permalink: nil)

    SlackThread.transaction do
      slack_threads.each(&:update_metadata)
      # destroy the job when finished
      destroy
    end
  end
end
