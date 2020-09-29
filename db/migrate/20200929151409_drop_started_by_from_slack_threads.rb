class DropStartedByFromSlackThreads < ActiveRecord::Migration[6.0]
  def change
    remove_column :slack_threads, :started_by
  end
end
