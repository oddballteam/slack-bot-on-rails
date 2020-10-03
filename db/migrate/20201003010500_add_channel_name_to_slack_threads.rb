# frozen_string_literal: true

class AddChannelNameToSlackThreads < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_threads, :channel_name, :string
    rename_column :slack_threads, :channel, :channel_id
  end
end
