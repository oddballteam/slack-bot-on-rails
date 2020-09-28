# frozen_string_literal: true

class AddTimestampsToSlackThreads < ActiveRecord::Migration[6.0]
  def change
    add_timestamps(:slack_threads)
  end
end
