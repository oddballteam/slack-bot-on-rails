# frozen_string_literal: true

class CreateGithubInstallations < ActiveRecord::Migration[6.0]
  def change
    create_table :github_installations do |t|
      t.integer :github_id
      t.datetime :token_expires_at
      t.string :repository
      t.string :access_token
      t.jsonb :metadata

      t.timestamps
    end
  end
end
