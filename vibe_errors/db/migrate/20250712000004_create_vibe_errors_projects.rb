class CreateVibeErrorsProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_projects do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :team, null: true, foreign_key: { to_table: :vibe_errors_teams }
      t.boolean :active, default: true
      t.string :repository_url
      t.string :environment
      t.json :metadata

      t.timestamps
    end

    add_index :vibe_errors_projects, :name, unique: true
    add_index :vibe_errors_projects, :slug, unique: true
    add_index :vibe_errors_projects, :active
    add_index :vibe_errors_projects, :environment
  end
end