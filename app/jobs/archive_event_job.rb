# frozen_string_literal: true

# log to Loki for long-term storage
# delete the event (or status: archived?)
# is Loki or Postgres best for this data to be warehoused?
class ArchiveEventJob < ApplicationJob
end
