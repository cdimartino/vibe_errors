class CreateVibeErrorsTags < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_tags do |t|
      t.string :name, null: false
      t.string :color
      t.text :description
      t.json :metadata

      t.timestamps
    end

    add_index :vibe_errors_tags, :name, unique: true
  end
end