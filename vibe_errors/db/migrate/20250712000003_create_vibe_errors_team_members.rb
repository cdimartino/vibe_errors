class CreateVibeErrorsTeamMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :vibe_errors_team_members do |t|
      t.references :team, null: false, foreign_key: { to_table: :vibe_errors_teams }
      t.references :owner, null: false, foreign_key: { to_table: :vibe_errors_owners }
      t.string :role, default: "member"
      t.datetime :joined_at

      t.timestamps
    end

    add_index :vibe_errors_team_members, [:team_id, :owner_id], unique: true
    add_index :vibe_errors_team_members, :role
  end
end