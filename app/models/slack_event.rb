# frozen_string_literal: true

# store metadata from Slack events
class SlackEvent < ApplicationRecord
  validates_presence_of :metadata

  # slack channel where the message was sent
  def channel
    metadata&.dig('event', 'channel')
  end

  # event timestamp
  def event_ts
    metadata&.dig('event', 'event_ts')
  end

  # event team id
  def team
    metadata&.dig('event', 'team')
  end

  # thread timestamp
  def thread_ts
    metadata&.dig('event', 'thread_ts') || event_ts
  end
end
