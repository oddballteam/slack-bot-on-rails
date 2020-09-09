# frozen_string_literal: true
require 'net/http'
require 'uri'

# a simple slack echo bot
class Say < SlackRubyBot::Bot
  @id = 0

  def self.datetime_from_message_ts(message_ts:, format: :long, default: DateTime.now)
    time = Time.at(message_ts.split('.').first.to_i) rescue default
    I18n.l(time, format: :long)
  end

  def self.next_id
    @id = @id % 10 + 1
  end

  def self.permalink_for(client:, channel:, message_ts:)
    response = client.web_client.chat_getPermalink(channel: channel, message_ts: message_ts)
    response&.permalink
  end

  # => {"client_msg_id"=>"36559e74-dd4a-47f1-a9db-277b9bf9fa49",
  #   "suppress_notification"=>false,
  #   "type"=>"message",
  #   "text"=>"<@U01AUCR7LJU> track",
  #   "user"=>"U0156PV963E",
  #   "team"=>"T1ZD0UBMZ",
  #   "blocks"=>
  #    [{"type"=>"rich_text",
  #      "block_id"=>"3/E",
  #      "elements"=>
  #       [{"type"=>"rich_text_section",
  #         "elements"=>
  #          [{"type"=>"user", "user_id"=>"U01AUCR7LJU"},
  #           {"type"=>"text", "text"=>" track"}]}]}],
  #   "thread_ts"=>".010500",
  #   "source_team"=>"T1ZD0UBMZ",1599245993
  #   "user_team"=>"T1ZD0UBMZ",
  #   "channel"=>"C019CUZB3AS",
  #   "event_ts"=>"1599247956.016900",
  #   "ts"=>"1599247956.016900"}
  command 'track' do |client, data, match|
    # done: link to the thread
    # done: date/timestamp of anything: first message in thread, @ ping
    # n2h: thread reporter
    # n2h: last message in thread's timestamp
    # reply-in-thread

    channel = data.channel
    # message = data.ts.gsub('.', '')
    # team = data.user_team
    message_ts = data.thread_ts || data.ts

    uri = permalink_for(client: client, channel: channel, message_ts: message_ts)
    started_at = datetime_from_message_ts(message_ts: message_ts)
    text = "Now tracking <#{uri}|this thread>, which started at #{started_at}."

    Rails.cache.write next_id, { text: text }

    client.say(
      channel: channel,
      text: text,
      thread_ts: message_ts
    )
  end

  # command 'reply in thread' do |client, data, match|
  #   client.say(
  #     channel: data.channel,
  #     text: "let's avoid spamming everyone, I will tell you what you need in this thread",
  #     thread_ts: data.thread_ts || data.ts
  #   )
  # end
end
