# frozen_string_literal: true

class AddIssueUrlToSlackThreads < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_threads, :issue_url, :string
  end
end
