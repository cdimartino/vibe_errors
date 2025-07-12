class CreateVibeErrorsErrorTags < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_error_tags do |t|
      t.references :error, null: false, foreign_key: { to_table: :vibe_errors_errors }
      t.references :tag, null: false, foreign_key: { to_table: :vibe_errors_tags }

      t.timestamps
    end

    add_index :vibe_errors_error_tags, [:error_id, :tag_id], unique: true
  end
end