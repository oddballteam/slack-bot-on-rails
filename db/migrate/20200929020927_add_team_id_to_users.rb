# frozen_string_literal: true

class AddTeamIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :team, foreign_key: true
  end
end
