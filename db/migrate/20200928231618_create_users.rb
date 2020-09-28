# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :slack_id
      t.string :display_name
      t.string :real_name
      t.string :image_url

      t.timestamps
    end
  end
end
