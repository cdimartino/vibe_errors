module VibeErrors
  class Team < ApplicationRecord
    self.table_name = "vibe_errors_teams"

    has_many :errors, dependent: :nullify
    has_many :messages, dependent: :nullify
    has_many :team_members, dependent: :destroy
    has_many :owners, through: :team_members
    has_many :projects, dependent: :nullify

    validates :name, presence: true, uniqueness: true
    validates :slug, presence: true, uniqueness: true

    scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
    scope :active, -> { where(active: true) }

    before_validation :generate_slug, if: :name_changed?

    def error_count
      errors.count
    end

    def message_count
      messages.count
    end

    def project_count
      projects.count
    end

    def member_count
      owners.count
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

    def add_member(owner)
      owners << owner unless owners.include?(owner)
    end

    def remove_member(owner)
      owners.delete(owner)
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
