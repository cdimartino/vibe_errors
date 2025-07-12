class CreateVibeErrorsFilePatterns < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_file_patterns do |t|
      t.references :owner, null: false, foreign_key: { to_table: :vibe_errors_owners }
      t.string :pattern, null: false
      t.text :description
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :vibe_errors_file_patterns, [:owner_id, :pattern], unique: true
    add_index :vibe_errors_file_patterns, :pattern
    add_index :vibe_errors_file_patterns, :active
  end
end