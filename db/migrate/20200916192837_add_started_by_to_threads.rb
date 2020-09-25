# frozen_string_literal: true

class AddStartedByToThreads < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_threads, :started_by, :string
  end
end
