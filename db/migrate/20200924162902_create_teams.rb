class CreateTeams < ActiveRecord::Migration[6.0]
  def change
    create_table :teams do |t|
      t.string :team_id
      t.string :name
      t.string :domain
      t.string :bot_access_token
      t.string :bot_user_id
      t.string :access_token
      t.string :user_id
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
