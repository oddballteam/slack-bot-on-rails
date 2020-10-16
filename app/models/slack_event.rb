# frozen_string_literal: true

# store metadata from Slack events
class SlackEvent < ApplicationRecord
  validates :metadata, presence: true
  validates :event_time, uniqueness: true

  COMMANDS = {
    'add category' => AddThreadCategoryJob,
    'add link' => AddThreadLinkJob,
    'categories' => ListThreadCategoriesJob,
    'close' => ResolveThreadJob,
    'link' => AddThreadLinkJob,
    'links' => ListThreadLinksJob,
    'list categories' => ListThreadCategoriesJob,
    'list links' => ListThreadLinksJob,
    'remove category' => RemoveThreadCategoryJob,
    'remove link' => RemoveThreadLinkJob,
    'resolve' => ResolveThreadJob,
    'track' => CreateThreadJob,
    'unlink' => RemoveThreadLinkJob
  }.freeze

  # slack channel where the message was sent
  def channel
    metadata&.dig('event', 'channel')
  end

  # convert chat commands the background jobs which processes them
  def enqueue_job
    COMMANDS.each do |command, job|
      next unless (matches = text&.match(/>\s+(?<command>#{command})(\s+(?<options>.*))?$/))

      return job.enqueue(event_id: id, options: matches['options'])
    end
    nil
  end

  # event timestamp
  def event_ts
    metadata&.dig('event', 'event_ts')
  end

  # event metadata
  def metadata=(metadata)
    super(metadata)
    self.event_time = metadata['event_time']
  end

  # event team id
  def team
    metadata&.dig('event', 'team')
  end

  # chat text that triggered this event
  def text
    metadata&.dig('event', 'text')
  end

  # thread timestamp
  def thread_ts
    metadata&.dig('event', 'thread_ts') || event_ts
  end

  # slack id of the user who sent the message
  def user
    metadata&.dig('event', 'user')
  end
end
