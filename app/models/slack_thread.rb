# frozen_string_literal: true

# model for a Slack threaded conversation
class SlackThread < ApplicationRecord
  acts_as_taggable_on :category, :link
  belongs_to :team
  belongs_to :user, optional: true, foreign_key: :started_by, inverse_of: :slack_threads
  alias_attribute :starter, :user

  scope :after, ->(date) { where('started_at >= ?', date) }
  scope :before, ->(date) { where('started_at < ?', date) }

  # convert Slack's ts format into a Rails DateTime
  def self.datetime_from_ts(slack_ts:, default: DateTime.now)
    Time.zone.at(slack_ts[0..9].to_i)
  rescue StandardError
    default
  end

  # find or init thread from SlackEvent
  def self.find_or_initialize_by_event(event)
    team = Team.find_by(slack_id: event.team)
    find_by(slack_ts: event.thread_ts) || new(
      channel_id: event.channel,
      slack_ts: event.thread_ts,
      started_at: datetime_from_ts(slack_ts: event.thread_ts),
      team: team
    )
  end

  # customize JSON output
  def as_json(options = {})
    super(options.merge(methods: %i[reply_users_names started_by_name]))
  end

  # formatted link for slack messages
  def formatted_link
    host = ENV['HEROKU_APP_NAME'] ? "#{ENV['HEROKU_APP_NAME']}.herokuapp.com" : 'localhost:3000'
    "<#{Rails.application.routes.url_helpers.thread_url(id, host: host, format: :json)}|this thread>"
  end

  # issue number, parsed from the issue url
  def issue_number
    issue_url[/\d+\Z/].to_i
  end

  # post message to slack thread
  def post_message(message)
    # https://api.slack.com/methods/chat.postMessage
    # scopes: chat:write
    slack_client.chat_postMessage(
      channel: channel_id,
      thread_ts: slack_ts,
      text: message
    )
  end

  # post private ephemeral reply to slack user
  def post_ephemeral_reply(message, user)
    # temporary hack for testing:
    post_message(message)
    # https://api.slack.com/methods/chat.postEphemeral
    # scopes: chat:write
    # slack_client.chat_postEphemeral(
    #   channel: channel_id,
    #   thread_ts: slack_ts,
    #   text: message,
    #   user: user
    # )
  end

  # the names for the reply_users ids
  def reply_users_names
    reply_users&.split(/[, ]+/)&.map do |reply_user_id|
      User.find(reply_user_id).real_name
    end&.join(', ')
  end

  # slack web client
  def slack_client
    team&.slack_client
  end

  # the name for the started_by user id
  def started_by_name
    user&.real_name
  end

  # lookup the thread permalink and channel name via the slack API
  def update_metadata
    # https://api.slack.com/methods/conversations.info
    # scopes: channels:read, groups:read, im:read, mpim:read
    response = slack_client.conversations_info(channel: channel_id)
    self.channel_name = response['channel']['name'] if response

    # https://api.slack.com/methods/chat.getPermalink
    # scopes: No scope required
    response = slack_client.chat_getPermalink(channel: channel_id, message_ts: slack_ts)
    self.permalink = response&.permalink

    save
  rescue Slack::Web::Api::Errors::MissingScope => _e
    false
  end

  # get the first message of the thread, which provides add'l metadata not contained in replies
  def update_replies
    # https://api.slack.com/methods/conversations.replies
    # scopes: channels:history, groups:history, im:history, mpim:history
    replies = slack_client.conversations_replies(channel: channel_id, ts: slack_ts, inclusive: true, limit: 1)
    message = replies['messages'].first
    self.starter ||= User.find_or_create_by(slack_id: message['user'], team: team)
    self.latest_reply_ts = message['latest_reply']
    self.reply_count = message['reply_count']
    self.reply_users = message['reply_users'].map do |reply_user|
      user = User.find_or_create_by(slack_id: reply_user, team: team)
      user.id
    end.join(', ')
    self.reply_users_count = message['reply_users_count']
    save
  rescue Slack::Web::Api::Errors::MissingScope => _e
    false
  end
end
