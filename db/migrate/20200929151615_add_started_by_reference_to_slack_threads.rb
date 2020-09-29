class AddStartedByReferenceToSlackThreads < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_threads, :started_by, :integer
    add_foreign_key :slack_threads, :users, column: :started_by
  end
end
