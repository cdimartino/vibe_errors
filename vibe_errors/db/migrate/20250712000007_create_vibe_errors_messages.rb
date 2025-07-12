class CreateVibeErrorsMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_messages do |t|
      t.text :content, null: false
      t.string :severity, null: false, default: "info"
      t.string :message_type, null: false, default: "log"
      t.text :context
      t.json :metadata

      t.references :owner, null: true, foreign_key: { to_table: :vibe_errors_owners }
      t.references :team, null: true, foreign_key: { to_table: :vibe_errors_teams }
      t.references :project, null: true, foreign_key: { to_table: :vibe_errors_projects }

      t.timestamps
    end

    add_index :vibe_errors_messages, :severity
    add_index :vibe_errors_messages, :message_type
    add_index :vibe_errors_messages, :created_at
  end
end