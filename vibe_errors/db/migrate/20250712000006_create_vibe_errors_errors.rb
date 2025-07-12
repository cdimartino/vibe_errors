class CreateVibeErrorsErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_errors do |t|
      t.text :message, null: false
      t.string :exception_class
      t.text :stack_trace
      t.string :location
      t.string :severity, null: false, default: "medium"
      t.string :status, null: false, default: "new"
      t.string :priority
      t.datetime :occurred_at
      t.datetime :resolved_at
      t.text :resolution
      t.integer :occurrence_count, default: 1
      t.string :checksum
      t.text :context
      t.json :metadata
      t.datetime :due_date

      t.references :owner, null: true, foreign_key: { to_table: :vibe_errors_owners }
      t.references :team, null: true, foreign_key: { to_table: :vibe_errors_teams }
      t.references :project, null: true, foreign_key: { to_table: :vibe_errors_projects }

      t.timestamps
    end

    add_index :vibe_errors_errors, :severity
    add_index :vibe_errors_errors, :status
    add_index :vibe_errors_errors, :priority
    add_index :vibe_errors_errors, :occurred_at
    add_index :vibe_errors_errors, :resolved_at
    add_index :vibe_errors_errors, :checksum
    add_index :vibe_errors_errors, :exception_class
    add_index :vibe_errors_errors, :due_date
    add_index :vibe_errors_errors, :created_at
  end
end