class CreateWeeks < ActiveRecord::Migration[7.0]
  def change
    create_table :weeks do |t|
      t.integer :season_id
      t.integer :week_number
      t.boolean :open
      t.datetime :start_date
      t.datetime :end_date
      t.datetime :deadline
      t.integer :default_team_id

      t.timestamps
    end
  end
end
