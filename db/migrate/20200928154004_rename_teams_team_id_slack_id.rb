# frozen_string_literal: true

class RenameTeamsTeamIdSlackId < ActiveRecord::Migration[6.0]
  def change
    rename_column :teams, :team_id, :slack_id
  end
end
