class CreateSlackThreads < ActiveRecord::Migration[6.0]
  def change
    create_table :slack_threads do |t|
      t.datetime :started_at
      t.datetime :ended_at
      t.string   :channel
      t.string   :slack_ts
      t.string   :permalink
    end
  end
end
