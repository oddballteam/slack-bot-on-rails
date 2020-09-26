# frozen_string_literal: true

# store metadata from Slack events
class SlackEvent < ApplicationRecord
  validates_presence_of :metadata
end
