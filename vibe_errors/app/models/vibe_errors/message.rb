module VibeErrors
  class Message < ApplicationRecord
    self.table_name = "vibe_errors_messages"

    has_many :message_tags, dependent: :destroy
    has_many :tags, through: :message_tags

    belongs_to :owner, class_name: "VibeErrors::Owner", optional: true
    belongs_to :team, class_name: "VibeErrors::Team", optional: true
    belongs_to :project, class_name: "VibeErrors::Project", optional: true

    validates :content, presence: true
    validates :severity, presence: true, inclusion: {in: %w[info warning error critical]}
    validates :message_type, presence: true, inclusion: {in: %w[log debug info warning error]}

    scope :by_severity, ->(severity) { where(severity: severity) }
    scope :by_type, ->(message_type) { where(message_type: message_type) }
    scope :by_owner, ->(owner_id) { where(owner_id: owner_id) }
    scope :by_team, ->(team_id) { where(team_id: team_id) }
    scope :by_project, ->(project_id) { where(project_id: project_id) }
    scope :recent, -> { order(created_at: :desc) }

    def self.create_from_message(content, options = {})
      message = new(
        content: content,
        severity: options[:severity] || "info",
        message_type: options[:message_type] || "log",
        context: options[:context],
        metadata: options[:metadata]
      )

      message.owner = options[:owner] if options[:owner]
      message.team = options[:team] if options[:team]
      message.project = options[:project] if options[:project]

      message.save!
      message
    end

    def add_tag(tag_name)
      tag = Tag.find_or_create_by(name: tag_name.downcase)
      tags << tag unless tags.include?(tag)
    end

    def remove_tag(tag_name)
      tag = tags.find_by(name: tag_name.downcase)
      tags.delete(tag) if tag
    end

    def critical?
      severity == "critical"
    end

    def error?
      severity == "error" || message_type == "error"
    end

    def warning?
      severity == "warning" || message_type == "warning"
    end

    def info?
      severity == "info" || message_type == "info"
    end
  end
end
