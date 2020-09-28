# frozen_string_literal: true

# model for a Slack threaded conversation
class SlackThread < ApplicationRecord
  acts_as_taggable_on :category
  belongs_to :team

  scope :after, ->(date) { where('started_at >= ?', date) }
  scope :before, ->(date) { where('started_at < ?', date) }

  # convert Slack's ts format into a Rails DateTime
  def self.datetime_from_ts(slack_ts:, default: DateTime.now)
    Time.at(slack_ts[0..9].to_i)
  rescue StandardError
    default
  end

  # find or init thread from SlackEvent
  def self.find_or_initialize_by_event(event)
    # TODO: started_by
    team = Team.find_by(team_id: event.team)
    find_by(slack_ts: event.thread_ts) || new(
      channel: event.channel,
      permalink: permalink_for_event(event),
      slack_ts: event.thread_ts,
      started_at: datetime_from_ts(slack_ts: event.thread_ts),
      team: team
    )
  end

  # get the permalink for the thread
  def self.permalink_for_event(event)
    team = Team.find_by(team_id: event.team)
    return unless team&.access_token&.present?

    client = Slack::Web::Client.new(token: team.access_token)
    # client.auth_test????
    response = client.chat_getPermalink(channel: event.channel, message_ts: event.thread_ts)
    response&.permalink
  end

  # formatted link for slack messages
  def formatted_link
    host = ENV['HEROKU_APP_NAME'] ? "#{ENV['HEROKU_APP_NAME']}.herokuapp.com" : 'localhost:3000'
    "<#{Rails.application.routes.url_helpers.thread_url(id, host: host)}|this thread>"
  end

  # post message to slack thread
  def post_message(message)
    slack_client.chat_postMessage(channel: channel, thread_ts: slack_ts, text: message)
  end

  # slack web client
  def slack_client
    team&.slack_client
  end

  # get the first message of the thread, which provides add'l metadata not contained in replies
  def update_conversation_details
    replies = slack_client.conversations_replies(channel: channel, ts: slack_ts, inclusive: true, limit: 1)
    message = replies['messages'].first
    self.started_by ||= message['user']
    self.latest_reply_ts = message['latest_reply']
    self.reply_count = message['reply_count']
    self.reply_users = message['reply_users'].join(', ')
    self.reply_users_count = message['reply_users_count']
    save
    # client.users_info(user: user_id) => name, email, avatars users
  end
end
