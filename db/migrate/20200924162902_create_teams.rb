# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.string :team_id
      t.string :name
      t.string :access_token
      t.string :bot_user_id
      t.string :user_access_token
      t.string :user_id
      t.boolean :active, default: true

      t.timestamps
    end

    add_reference :slack_threads, :team, foreign_key: true
  end
end
