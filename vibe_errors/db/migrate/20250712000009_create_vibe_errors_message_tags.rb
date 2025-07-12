class CreateVibeErrorsMessageTags < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_message_tags do |t|
      t.references :message, null: false, foreign_key: { to_table: :vibe_errors_messages }
      t.references :tag, null: false, foreign_key: { to_table: :vibe_errors_tags }

      t.timestamps
    end

    add_index :vibe_errors_message_tags, [:message_id, :tag_id], unique: true
  end
end