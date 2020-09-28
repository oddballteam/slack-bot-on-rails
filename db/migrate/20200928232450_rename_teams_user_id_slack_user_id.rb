# frozen_string_literal: true

class RenameTeamsUserIdSlackUserId < ActiveRecord::Migration[6.0]
  def change
    rename_column :teams, :user_id, :slack_user_id
  end
end
