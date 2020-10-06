# frozen_string_literal: true

class CreateSlackThreads < ActiveRecord::Migration[6.0]
  def change
    create_table :slack_threads do |t|
      t.datetime :started_at
      t.datetime :ended_at
      t.string :channel
      t.string :slack_ts
      t.string :started_by
      t.string :permalink
      t.string :latest_reply_ts
      t.integer :reply_count
      t.string :reply_users
      t.integer :reply_users_count

      t.timestamps
    end
  end
end
