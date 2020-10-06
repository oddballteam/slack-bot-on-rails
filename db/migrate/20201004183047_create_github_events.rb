# frozen_string_literal: true

class CreateGithubEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :github_events do |t|
      t.jsonb :metadata
      t.string :state

      t.timestamps
    end
  end
end
