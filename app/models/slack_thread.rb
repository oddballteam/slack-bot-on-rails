# frozen_string_literal: true

# model for a Slack threaded conversation
class SlackThread < ApplicationRecord
  acts_as_taggable_on :category

  scope :after, ->(date) { where('started_at >= ?', date) }
  scope :before, ->(date) { where('started_at < ?', date) }

  # convert Slack's ts format into a Rails DateTime
  def self.datetime_from_ts(ts:, default: DateTime.now)
    Time.at(ts[0..9].to_i)
  rescue StandardError
    default
  end

  def self.find_or_create_by_event(event)
    # TODO: started_by
    find_by(slack_ts: event.thread_ts) || new(
      channel: event.channel,
      permalink: permalink_for_event(event),
      slack_ts: event.thread_ts,
      started_at: datetime_from_ts(ts: event.thread_ts)
    )
  end

  # get the permalink for the thread
  def self.permalink_for_event(event)
    team = Team.find_by(team_id: event.team)
    return unless team&.access_token&.present?

    client = Slack::Web::Client.new(token: team.access_token)
    # client.auth_test????
    response = client.web_client.chat_getPermalink(channel: event.channel, message_ts: event.thread_ts)
    response&.permalink
  end

  # def last_slack_ts
  #   last_slack_ts
  # end

  # def latest_replies
  #   limit = 100
  #   oldest = @last_slack_ts

  #   response = slack.conversations_replies(
  #     channel: channel, ts: slack_ts, limit: limit, oldest: oldest, inclusive: true
  #   )

  #   return [] unless response.ok?

  #   if response.has_more?
  #     @last_slack_ts = response.messages.first.ts
  #     latest_replies
  #   else
  #     response.messages
  #   end
  # end

  # def first_message
  #   limit = 1

  #   response = slack.conversations_replies(
  #     channel: channel, ts: slack_ts, limit: limit, inclusive: true
  #   )

  #   return [] unless response.ok?

  #   response.messages
  # end

  private

  def slack
    @slack ||= Slack::Web::Client.new
  end
end
