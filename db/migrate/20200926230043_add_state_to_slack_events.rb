# frozen_string_literal: true

class AddStateToSlackEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_events, :state, :string
  end
end
