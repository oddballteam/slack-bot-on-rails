# frozen_string_literal: true

# add the given link to the current thread and
# reply in Slack thread w/ the updated link list.
class AddThreadLinkJob < ApplicationJob
  # Default settings for this job. These are optional - without them, jobs
  # will default to priority 100 and run immediately.
  # self.run_at = proc { 1.minute.from_now }

  # We use the Linux priority scale - a lower number is more important.
  self.priority = 100

  def run(event_id:, options:)
    event = SlackEvent.find(event_id)
    slack_thread = SlackThread.find_or_initialize_by_event(event)

    SlackThread.transaction do
      slack_thread.link_list.add(options)
      slack_thread.save
      event.update(state: 'replied')
      # destroy the job when finished
      destroy
    end

    # update issue description
    installation = GithubInstallation.last
    installation.link_issue(slack_thread) if installation&.repository&.present?

    # post message in slack thread
    message = render('slack_thread/links.slack', flash: "#{options} added.", slack_thread: slack_thread)
    slack_thread.post_ephemeral_reply(message, event.user)
  end
end
