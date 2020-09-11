# frozen_string_literal: true
require 'net/http'
require 'uri'

class SupportBot < SlackRubyBot::Bot
  help do
    title 'Support Bot'
    desc 'This bot tracks support threads.'

    command 'track' do
      desc 'Start tracking a thread.'
    end

    command 'add category <category>' do
      desc 'Add <category> to this thread\'s categories.'
    end

    command 'remove category <category>' do
      desc 'Remove <category> from this thread\'s categories.'
    end

    command 'list categories' do
      desc 'List this thread\'s categories.'
    end
  end

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

  command 'add category' do |client, data, match|
    thread = SlackThread.from_command(client: client, data: data)

    category = match['expression']
    thread.category_list.add(category)

    text = if thread.save
            "#{category} added. Categories: #{thread.category_list}."
           else
            thread.errors.full_messages.join('. ')
           end

    client.say(
      channel: thread.channel,
      text: text,
      thread_ts: thread.slack_ts
    )
  end

  command 'remove category' do |client, data, match|
    thread = SlackThread.from_command(client: client, data: data)

    category = match['expression']
    thread.category_list.remove(category)

    text = if thread.save
            "#{category} removed. Categories: #{thread.category_list}."
           else
            thread.errors.full_messages.join('. ')
           end

    client.say(
      channel: thread.channel,
      text: text,
      thread_ts: thread.slack_ts
    )
  end

  command 'categories', 'list categories' do |client, data, match|
    thread = SlackThread.from_command(client: client, data: data)

    client.say(
      channel: thread.channel,
      text: "Categories: #{thread.category_list}.",
      thread_ts: thread.slack_ts
    )
  end
end
