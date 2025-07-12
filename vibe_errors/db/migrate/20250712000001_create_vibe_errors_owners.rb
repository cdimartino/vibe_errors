class CreateVibeErrorsOwners < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_owners do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :first_name
      t.string :last_name
      t.string :github_username
      t.boolean :active, default: true
      t.text :bio
      t.string :avatar_url
      t.json :metadata

      t.timestamps
    end

    add_index :vibe_errors_owners, :email, unique: true
    add_index :vibe_errors_owners, :github_username, unique: true
    add_index :vibe_errors_owners, :name
    add_index :vibe_errors_owners, :active
  end
end