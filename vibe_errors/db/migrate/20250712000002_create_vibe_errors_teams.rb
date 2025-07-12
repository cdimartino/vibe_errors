class CreateVibeErrorsTeams < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_teams do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :active, default: true
      t.string :color
      t.json :metadata

      t.timestamps
    end

    add_index :vibe_errors_teams, :name, unique: true
    add_index :vibe_errors_teams, :slug, unique: true
    add_index :vibe_errors_teams, :active
  end
end