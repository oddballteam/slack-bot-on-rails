# frozen_string_literal: true
require 'net/http'
require 'uri'

class SupportBot < SlackRubyBot::Bot
  command 'track' do |client, data, match|
    thread = SlackThread.from_command(client: client, data: data)

    text = if thread.persisted?
            'This thread is already being tracked. :smiel:'
           elsif thread.save
            thread.now_tracking
           else
            thread.errors.full_messages.join('. ')
           end

    client.say(
      channel: thread.channel,
      text: text,
      thread_ts: thread.slack_ts
    )
  end

  # command 'tag' do |client, data, match|
  #   thread = SlackThread.from_command(client: client, data: data)

  #   text = if thread.save
  #           thread.now_tracking
  #          else
  #           thread.errors.full_messages.join('. ')
  #          end

  #   client.say(
  #     channel: thread.channel,
  #     text: text,
  #     thread_ts: thread.slack_ts
  #   )
  # end
end
