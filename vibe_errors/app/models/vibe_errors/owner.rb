module VibeErrors
  class Owner < ApplicationRecord
    self.table_name = "vibe_errors_owners"

    has_many :errors, dependent: :nullify
    has_many :messages, dependent: :nullify
    has_many :team_members, dependent: :destroy
    has_many :teams, through: :team_members
    has_many :file_patterns, dependent: :destroy

    validates :name, presence: true
    validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
    validates :github_username, uniqueness: true, allow_nil: true

    scope :by_name, ->(name) { where("name ILIKE ?", "%#{name}%") }
    scope :by_email, ->(email) { where("email ILIKE ?", "%#{email}%") }
    scope :active, -> { where(active: true) }

    def full_name
      [first_name, last_name].compact.join(" ").presence || name
    end

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

    def active?
      active
    end
  end
end
