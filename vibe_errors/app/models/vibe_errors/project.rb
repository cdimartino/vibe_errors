module VibeErrors
  class Project < ApplicationRecord
    self.table_name = "vibe_errors_projects"

    has_many :errors, dependent: :nullify
    has_many :messages, dependent: :nullify
    belongs_to :team, class_name: "VibeErrors::Team", optional: true

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true

    scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
    scope :active, -> { where(active: true) }
    scope :by_team, ->(team_id) { where(team_id: team_id) }

    before_validation :generate_slug, if: :name_changed?

    def error_count
      errors.count
    end

    def message_count
      messages.count
    end

    def recent_errors(limit = 10)
      errors.recent.limit(limit)
    end

    def critical_errors
      errors.where(severity: "critical")
    end

    def unresolved_errors
      errors.where.not(status: "resolved")
    end

    def resolved_errors
      errors.where(status: "resolved")
    end

    def error_resolution_rate
      total = errors.count
      return 0 if total.zero?

      resolved = resolved_errors.count
      (resolved.to_f / total * 100).round(2)
    end

    def active?
      active
    end

    private

    def generate_slug
      self.slug = name.parameterize if name.present?
    end
  end
end
