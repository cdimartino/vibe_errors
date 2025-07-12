module VibeErrors
  class TeamMember < ApplicationRecord
    self.table_name = "vibe_errors_team_members"

    belongs_to :team, class_name: "VibeErrors::Team"
    belongs_to :owner, class_name: "VibeErrors::Owner"

    validates :team_id, uniqueness: {scope: :owner_id}
    validates :role, inclusion: {in: %w[member lead admin]}, allow_nil: true

    scope :by_role, ->(role) { where(role: role) }
    scope :leads, -> { where(role: "lead") }
    scope :admins, -> { where(role: "admin") }

    def lead?
      role == "lead"
    end

    def admin?
      role == "admin"
    end

    def member?
      role == "member" || role.blank?
    end
  end
end
