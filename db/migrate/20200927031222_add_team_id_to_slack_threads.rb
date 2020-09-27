# frozen_string_literal: true

class AddTeamIdToSlackThreads < ActiveRecord::Migration[6.0]
  def change
    add_reference :slack_threads, :team, foreign_key: true
  end
end
