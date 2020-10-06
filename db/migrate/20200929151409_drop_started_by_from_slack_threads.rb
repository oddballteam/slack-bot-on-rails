# frozen_string_literal: true

class DropStartedByFromSlackThreads < ActiveRecord::Migration[6.0]
  def change
    remove_column :slack_threads, :started_by, :string
  end
end
