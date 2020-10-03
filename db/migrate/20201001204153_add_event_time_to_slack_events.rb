# frozen_string_literal: true

class AddEventTimeToSlackEvents < ActiveRecord::Migration[6.0]
  def change
    add_column :slack_events, :event_time, :integer
  end
end
