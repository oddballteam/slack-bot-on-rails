class SlackThread < ApplicationRecord
  acts_as_taggable_on :category

  scope :after, ->(date) { where("started_at >= ?", date) }
  scope :before, ->(date) { where("started_at < ?", date) }

  def self.datetime_from_message_ts(message_ts:, default: DateTime.now)
    Time.at(message_ts.split('.').first.to_i) rescue default
  end

  def self.from_command(client:, data:)
    channel = data.channel
    message_ts = data.thread_ts || data.ts
    permalink = permalink_for(client: client, channel: channel, message_ts: message_ts)
    started_at = datetime_from_message_ts(message_ts: message_ts)
    find_by(slack_ts: message_ts) || new(
      channel: channel, permalink: permalink, slack_ts: message_ts, started_at: started_at
    )
  end

  def self.permalink_for(client:, channel:, message_ts:)
    response = client.web_client.chat_getPermalink(channel: channel, message_ts: message_ts)
    response&.permalink
  end

  # Move this into a view?
  def now_tracking
    <<~EOS
      Now tracking <#{permalink}|this thread>,
      which started at #{ I18n.l(started_at, format: :long) }.
    EOS
  end

  def latest_replies
    limit = 100
    oldest = @last_slack_ts

    response = slack.conversations_replies(
      channel: channel, ts: slack_ts, limit: limit, oldest: oldest, inclusive: true
    )

    return [] unless response.ok?

    if response.has_more?
      @last_slack_ts = response.messages.first.ts
      latest_replies
    else
      response.messages
    end
  end

  private

  def slack
    @slack ||= Slack::Web::Client.new
  end
end
