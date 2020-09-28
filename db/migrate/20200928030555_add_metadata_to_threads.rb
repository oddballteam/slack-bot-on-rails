# frozen_string_literal: true

class AddMetadataToThreads < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_threads, :latest_reply_ts, :string
    add_column :slack_threads, :reply_count, :integer
    add_column :slack_threads, :reply_users, :string
    add_column :slack_threads, :reply_users_count, :integer
  end
end
